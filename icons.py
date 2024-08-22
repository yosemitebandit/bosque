from PIL import Image


def resize_app_icon(input_path):
    """
    Resizes a 1024px square image to the required macOS app icon sizes.

    Args:
        input_path: The path to the input image (1024x1024 pixels).
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
                resized_img = img.resize(
                    new_size, Image.LANCZOS
                )  # Use LANCZOS for high-quality resizing
                output_filename = f"Icon-App-{width}x{height}@{scale}x.png"
                resized_img.save(output_filename)
                print(f"Saved: {output_filename}")

    except (IOError, ValueError) as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    input_image_path = input("Enter the path to your 1024x1024 image: ")
    resize_app_icon(input_image_path)
