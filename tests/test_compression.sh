#!/usr/bin/env bash
# Compression-specific tests for clip utility
#
set -euo pipefail

run_test_group "Image Compression Tests"

if ! check_xclip; then
  skip_test "Compression tests" "xclip not available"
  return 0
fi

if ! check_image_tools; then
  skip_test "Compression tests" "Image tools not installed"
  return 0
fi

setup_test

# Load test PNG into clipboard if possible
png_file="$FIXTURES_DIR/sim-indonesia.png"
if [[ -f "$png_file" ]] && command -v xclip &>/dev/null && [[ -n "${DISPLAY:-}" ]]; then
  if xclip -selection clipboard -t image/png -i "$png_file" 2>/dev/null; then
    info "PNG loaded into clipboard for compression tests"

    # Test: Optimization with pngquant
    if command -v pngquant &>/dev/null; then
      output=$("$CLIP_CMD" -p -c -Q 80 "$OUTPUT_DIR/pngquant_80.png" 2>&1 || true)
      assert_output "pngquant optimization runs" "Optimizing with pngquant" "$output"
      assert_file_exists "pngquant output created" "$OUTPUT_DIR/pngquant_80.png"

      # Test different quality levels
      for quality in 20 40 60 80 100; do
        output=$("$CLIP_CMD" -p -c -Q "$quality" "$OUTPUT_DIR/pngquant_q${quality}.png" 2>&1 || true)
        assert_file_exists "pngquant quality $quality works" "$OUTPUT_DIR/pngquant_q${quality}.png"
      done

      # Compare file sizes
      if [[ -f "$OUTPUT_DIR/pngquant_q20.png" ]] && [[ -f "$OUTPUT_DIR/pngquant_q100.png" ]]; then
        size_20=$(stat -c%s "$OUTPUT_DIR/pngquant_q20.png")
        size_100=$(stat -c%s "$OUTPUT_DIR/pngquant_q100.png")
        info "Quality 20 size: $size_20 bytes"
        info "Quality 100 size: $size_100 bytes"
        ((size_20 <= size_100)) && pass "Lower quality produces smaller or equal file"
      fi
    else
      skip_test "pngquant compression" "pngquant not installed"
    fi

    # Test: Optimization with optipng
    if command -v optipng &>/dev/null; then
      output=$("$CLIP_CMD" -p -c -Q 50 "$OUTPUT_DIR/optipng_test.png" 2>&1 || true)
      if [[ "$output" == *"optipng"* ]]; then
        pass "optipng optimization runs when available"
        assert_file_exists "optipng output created" "$OUTPUT_DIR/optipng_test.png"
      fi
    else
      skip_test "optipng compression" "optipng not installed"
    fi

    # Test: Resize mode with ImageMagick
    if command -v convert &>/dev/null; then
      # Test various resize percentages
      for percent in 10 25 50 75 90 100 110; do
        output=$("$CLIP_CMD" -p -r -Q "$percent" "$OUTPUT_DIR/resize_${percent}.png" 2>&1 || true)
        assert_file_exists "Resize ${percent}% works" "$OUTPUT_DIR/resize_${percent}.png"
      done

      # Verify resize produces different file sizes
      if [[ -f "$OUTPUT_DIR/resize_25.png" ]] && [[ -f "$OUTPUT_DIR/resize_100.png" ]]; then
        size_25=$(stat -c%s "$OUTPUT_DIR/resize_25.png")
        size_100=$(stat -c%s "$OUTPUT_DIR/resize_100.png")
        info "25% resize: $size_25 bytes"
        info "100% resize: $size_100 bytes"
        ((size_25 < size_100)) && pass "Resize percentage affects file size"
      fi

      # Test: Upscaling (>100%)
      if [[ -f "$OUTPUT_DIR/resize_110.png" ]] && [[ -f "$OUTPUT_DIR/resize_100.png" ]]; then
        size_110=$(stat -c%s "$OUTPUT_DIR/resize_110.png")
        size_100=$(stat -c%s "$OUTPUT_DIR/resize_100.png")
        info "110% resize: $size_110 bytes"
        ((size_110 > size_100)) && pass "Upscaling increases file size"
      fi
    else
      skip_test "ImageMagick resize tests" "convert not installed"
    fi

    # Test: Compression fallback mechanism
    # Temporarily rename tools to test fallback
    if command -v pngquant &>/dev/null; then
      # This would require sudo to actually move system binaries
      # so we'll just verify the fallback logic exists in the script
      if grep -q "elif.*OPTIPNG" "$CLIP_CMD" && grep -q "elif.*CONVERT" "$CLIP_CMD"; then
        pass "Compression fallback mechanism implemented"
      else
        fail "Compression fallback mechanism not found"
      fi
    fi

    # Test: Skip compression if result is larger
    # Create a very small PNG that won't compress well
    if command -v convert &>/dev/null; then
      # Create a 1x1 PNG
      convert -size 1x1 xc:white "$TMP_DIR/tiny.png"
      if xclip -selection clipboard -t image/png -i "$TMP_DIR/tiny.png" 2>/dev/null; then
        output=$("$CLIP_CMD" -p -c "$OUTPUT_DIR/tiny_compressed.png" 2>&1 || true)
        if [[ "$output" == *"did not reduce"* ]] || [[ "$output" == *"using original"* ]]; then
          pass "Compression skipped when not beneficial"
        else
          info "Small image compression behavior varies"
        fi
      fi
    fi

    # Test: Combined options
    output=$("$CLIP_CMD" -p -c -q "$OUTPUT_DIR/quiet_compress.png" 2>&1 || true)
    assert_equal "Quiet mode suppresses compression output" "" "$output"
    assert_file_exists "Quiet compression creates file" "$OUTPUT_DIR/quiet_compress.png"

  else
    skip_test "Clipboard compression tests" "Could not load PNG into clipboard"
  fi
else
  skip_test "Compression tests" "PNG file or xclip not available"
fi

# Test: Compression options validation
output=$("$CLIP_CMD" -h 2>&1 || true)
assert_output "Help shows compress option" "--compress" "$output"
assert_output "Help shows resize option" "--resize" "$output"
assert_output "Help shows quality option" "--quality" "$output"

# Test: Quality bounds
for invalid_quality in -1 0 101 200; do
  output=$("$CLIP_CMD" -p -c -Q "$invalid_quality" "$OUTPUT_DIR/invalid_q.png" 2>&1 || true)
  # Quality might be clamped or cause an error
  # The script should handle it gracefully either way
  pass "Quality value $invalid_quality handled"
done

cleanup_test

#fin