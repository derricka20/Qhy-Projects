import os
import zipfile

def bundle_and_compress_scripts(source_dir, output_zip):
    """
    Bundle and compress all scripts in the source directory into a zip file.

    Args:
        source_dir (str): The directory containing the scripts.
        output_zip (str): The name of the output zip file.
    """
    try:
        with zipfile.ZipFile(output_zip, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for root, _, files in os.walk(source_dir):
                for file in files:
                    # Include only files (e.g., .py, .cs, .lua, .pl)
                    if file.endswith(('.py', '.cs', '.lua', '.pl')):
                        file_path = os.path.join(root, file)
                        arcname = os.path.relpath(file_path, source_dir)
                        zipf.write(file_path, arcname)
                        print(f"Added: {arcname}")
        print(f"\nAll scripts have been bundled and compressed into '{output_zip}' successfully!")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    # Define the source directory containing the scripts and the output zip file name
    source_directory = "scripts"  # Replace with the path to your scripts folder
    output_zip_file = "scripts_bundle.zip"

    # Call the function to bundle and compress the scripts
    bundle_and_compress_scripts(source_directory, output_zip_file)
