import argparse

from PIL import Image


def resize_app_icon(input_path, border_percentage=0.065):
    """
    Resizes a 1024px square image to the required macOS app icon sizes with a transparent border.

    Args:
        input_path: The path to the input image (1024x1024 pixels).
        border_percentage: The percentage of the icon size to use as the border (default: 0.065, which is approximately 68 pixels for a 1024x1024 image).
    """

    required_sizes = {
        "16x16": [1, 2],
        "32x32": [1, 2],
        "128x128": [1, 2],
        "256x256": [1, 2],
        "512x512": [1, 2],
    }

    try:
        img = Image.open(input_path)

        if img.size != (1024, 1024):
            raise ValueError("Input image must be 1024x1024 pixels")

        for size, scales in required_sizes.items():
            width, height = map(int, size.split("x"))
            for scale in scales:
                new_size = (width * scale, height * scale)

                # Calculate border size based on percentage
                border_size = int(min(new_size[0], new_size[1]) * border_percentage)

                resized_image_width = new_size[0] - 2 * border_size
                resized_image_height = new_size[1] - 2 * border_size

                if resized_image_width <= 0 or resized_image_height <= 0:
                    raise ValueError(
                        f"Border percentage ({border_percentage}) is too large for icon size {size}@{scale}x. Reduce the percentage or skip this size."
                    )

                resized_img = img.resize(
                    (resized_image_width, resized_image_height), Image.LANCZOS
                )

                final_img = Image.new("RGBA", new_size, (0, 0, 0, 0))
                paste_position = (border_size, border_size)
                final_img.paste(resized_img, paste_position)

                output_filename = f"Icon-App-{width}x{height}@{scale}x.png"
                final_img.save(output_filename)
                print(f"Saved: {output_filename}")

    except (IOError, ValueError) as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Resize a 1024px square image to macOS app icon sizes with a transparent border."
    )
    parser.add_argument("input_path", help="Path to the input image (1024x1024 pixels)")
    parser.add_argument(
        "--border_percentage",
        type=float,
        default=0.065,
        help="Border percentage (default: 0.065)",
    )
    args = parser.parse_args()

    resize_app_icon(args.input_path, args.border_percentage)
