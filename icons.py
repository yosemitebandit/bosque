import argparse

from PIL import Image, ImageDraw


def resize_app_icon(input_path, border_percentage=0.1, corner_radius_percentage=0.2):
    """
    Resizes a 1024px square image to the required macOS app icon sizes with a transparent border and rounded corners.

    Args:
        input_path: The path to the input image (1024x1024 pixels).
        border_percentage: The percentage of the icon size to use as the border (default: 0.1).
        corner_radius_percentage: The percentage of the icon's smaller dimension to use as the corner radius (default: 0.2).
    """

    required_sizes = {
        "16x16": [1, 2],
        "32x32": [1, 2],
        "128x128": [1, 2],
        "256x256": [1, 2],
        "512x512": [1, 2],
    }

    try:
        img = Image.open(input_path).convert("RGBA")

        if img.size != (1024, 1024):
            raise ValueError("Input image must be 1024x1024 pixels")

        for size, scales in required_sizes.items():
            width, height = map(int, size.split("x"))
            for scale in scales:
                new_size = (width * scale, height * scale)

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

                # Calculate corner radius based on percentage
                corner_radius = int(
                    min(resized_img.width, resized_img.height)
                    * corner_radius_percentage
                )

                # Create a rounded mask for the resized image
                mask = Image.new("L", resized_img.size, 0)
                draw = ImageDraw.Draw(mask)
                draw.rounded_rectangle(
                    [(0, 0), resized_img.size], corner_radius, fill=255
                )

                final_img = Image.new("RGBA", new_size, (0, 0, 0, 0))
                paste_position = (border_size, border_size)

                final_img.paste(resized_img, paste_position, mask)

                output_filename = f"Icon-App-{width}x{height}@{scale}x.png"
                final_img.save(output_filename)
                print(f"Saved: {output_filename}")

    except (IOError, ValueError) as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Resize a 1024px square image to macOS app icon sizes with a transparent border and rounded corners."
    )
    parser.add_argument("input_path", help="Path to the input image (1024x1024 pixels)")
    parser.add_argument(
        "--border_percentage",
        type=float,
        default=0.1,
        help="Border percentage (default: 0.1)",
    )
    parser.add_argument(
        "--corner_radius_percentage",
        type=float,
        default=0.2,
        help="Corner radius percentage (default: 0.2)",
    )
    args = parser.parse_args()

    resize_app_icon(
        args.input_path, args.border_percentage, args.corner_radius_percentage
    )
