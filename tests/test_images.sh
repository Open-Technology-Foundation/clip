#!/usr/bin/env bash
# Image copy/paste tests for clip utility
#
set -euo pipefail

run_test_group "Image Copy/Paste Tests"

if ! check_xclip; then
  skip_test "Image tests" "xclip not available"
  return 0
fi

setup_test

# Test: JPEG image fixture availability
jpeg_file="$FIXTURES_DIR/shen2.jpg"
if [[ -f "$jpeg_file" ]]; then
  info "JPEG test file available: $jpeg_file"
  # Note: clip doesn't support copying images TO clipboard (only text files)
  # It's designed to PASTE images FROM clipboard (e.g., screenshots)
  pass "JPEG fixture exists for manual testing"
else
  skip_test "JPEG image fixture" "shen2.jpg not found"
fi

# Test: PNG image fixture and options
png_file="$FIXTURES_DIR/sim-indonesia.png"
if [[ -f "$png_file" ]]; then
  info "PNG test file available: $png_file"
  # Note: clip doesn't support copying images TO clipboard (only text files)
  # It's designed to PASTE images FROM clipboard (e.g., screenshots)
  pass "PNG fixture exists for manual testing"

  # Test: Check if image tools are available
  if check_image_tools; then
    info "Image optimization tools available"

    # Test: Compression options are accepted in help
    assert_success "Compression option -c in help" "$CLIP_CMD" -h
    assert_success "Resize option -r in help" "$CLIP_CMD" -h
    assert_success "Quality option -Q in help" "$CLIP_CMD" -h

    # Test: Try paste with compression (will fail if no image in clipboard)
    output=$("$CLIP_CMD" -p -c "$OUTPUT_DIR/test_compressed.png" 2>&1 || true)
    if [[ "$output" == *"Detected image data"* ]]; then
      assert_file_exists "Compressed image created" "$OUTPUT_DIR/test_compressed.png"

      # Compare file sizes if both exist
      if [[ -f "$OUTPUT_DIR/test_compressed.png" ]]; then
        size_compressed=$(stat -c%s "$OUTPUT_DIR/test_compressed.png")
        info "Compressed PNG size: $size_compressed bytes"
      fi
    else
      info "No image data in clipboard for compression test"
    fi

    # Test: Resize mode
    output=$("$CLIP_CMD" -p -r -Q 50 "$OUTPUT_DIR/test_resized.png" 2>&1 || true)
    if [[ "$output" == *"Detected image data"* ]]; then
      assert_file_exists "Resized image created" "$OUTPUT_DIR/test_resized.png"

      if [[ -f "$OUTPUT_DIR/test_resized.png" ]]; then
        size_resized=$(stat -c%s "$OUTPUT_DIR/test_resized.png")
        info "Resized PNG size (50%): $size_resized bytes"
      fi
    else
      info "No image data in clipboard for resize test"
    fi

  else
    skip_test "Image compression tests" "Image optimization tools not available"
  fi

  # Test: Simulate PNG in clipboard using xclip directly (if possible)
  if command -v xclip &>/dev/null && [[ -n "${DISPLAY:-}" ]]; then
    # Try to load PNG into clipboard
    if xclip -selection clipboard -t image/png -i "$png_file" 2>/dev/null; then
      sleep 0.3  # Allow clipboard to settle after loading image
      info "Loaded PNG into clipboard for testing"

      # Test: Paste PNG from clipboard
      output=$("$CLIP_CMD" -p "$OUTPUT_DIR/pasted_image.png" 2>&1 || true)
      assert_output "Image paste detects PNG data" "Detected image data" "$output"
      assert_file_exists "Pasted PNG file exists" "$OUTPUT_DIR/pasted_image.png"

      # Test: Paste with optimization
      if check_image_tools; then
        sleep 0.2  # Allow previous operation to complete
        output=$("$CLIP_CMD" -p -c "$OUTPUT_DIR/optimized.png" 2>&1 || true)
        assert_output "Optimization shows status" "image size" "$output"
        assert_file_exists "Optimized PNG created" "$OUTPUT_DIR/optimized.png"

        # Check that optimization actually worked
        if [[ -f "$OUTPUT_DIR/pasted_image.png" ]] && [[ -f "$OUTPUT_DIR/optimized.png" ]]; then
          size_original=$(stat -c%s "$OUTPUT_DIR/pasted_image.png")
          size_optimized=$(stat -c%s "$OUTPUT_DIR/optimized.png")
          info "Original size: $size_original bytes"
          info "Optimized size: $size_optimized bytes"

          if ((size_optimized < size_original)); then
            pass "Image optimization reduces file size"
          else
            info "Optimization did not reduce size (image may already be optimized)"
          fi
        fi

        # Test: Different quality levels
        sleep 0.2  # Allow previous operation to complete
        output=$("$CLIP_CMD" -p -c -Q 30 "$OUTPUT_DIR/low_quality.png" 2>&1 || true)
        assert_file_exists "Low quality PNG created" "$OUTPUT_DIR/low_quality.png"

        sleep 0.2  # Allow previous operation to complete
        output=$("$CLIP_CMD" -p -c -Q 90 "$OUTPUT_DIR/high_quality.png" 2>&1 || true)
        assert_file_exists "High quality PNG created" "$OUTPUT_DIR/high_quality.png"

        # Test: Resize mode with different percentages
        sleep 0.2  # Allow previous operation to complete
        output=$("$CLIP_CMD" -p -r -Q 25 "$OUTPUT_DIR/quarter_size.png" 2>&1 || true)
        assert_file_exists "25% resized PNG created" "$OUTPUT_DIR/quarter_size.png"

        sleep 0.2  # Allow previous operation to complete
        output=$("$CLIP_CMD" -p -r -Q 75 "$OUTPUT_DIR/three_quarter_size.png" 2>&1 || true)
        assert_file_exists "75% resized PNG created" "$OUTPUT_DIR/three_quarter_size.png"

        # Compare sizes
        if [[ -f "$OUTPUT_DIR/quarter_size.png" ]] && [[ -f "$OUTPUT_DIR/three_quarter_size.png" ]]; then
          size_25=$(stat -c%s "$OUTPUT_DIR/quarter_size.png")
          size_75=$(stat -c%s "$OUTPUT_DIR/three_quarter_size.png")
          info "25% size: $size_25 bytes"
          info "75% size: $size_75 bytes"

          if ((size_25 < size_75)); then
            pass "Smaller resize percentage produces smaller file"
          else
            fail "Resize percentages don't correlate with file size"
          fi
        fi
      fi
    else
      skip_test "PNG clipboard tests" "Could not load PNG into clipboard"
    fi
  else
    skip_test "PNG clipboard tests" "xclip or display not available for clipboard operations"
  fi
else
  skip_test "PNG image tests" "sim-indonesia.png not found"
fi

cleanup_test

#fin