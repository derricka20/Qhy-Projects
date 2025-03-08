import os

# Define the directory structure and files
file_tree = {
    "Qhy-Projects": {
        "DDSV": {
            "src": {
                "ddsv_core.pl": "",
                "linking_system.pl": "",
                "text_manipulation.pl": "",
                "utils": {
                    "data_helpers.pl": "",
                    "analytics_tools.pl": "",
                },
            },
            "data": {},
            "extensions": {
                "cross_platform": {},
                "gui": {},
                "machine_learning": {},
            },
            "tests": {
                "core_tests.pl": "",
                "integration_tests.pl": "",
            },
        },
        "docs": {
            "README.md": "",
            "ddsv_design.md": "",
            "extensions_docs.md": "",
            "api_docs": {},
        },
        "examples": {
            "chatbot": {},
            "dynamic_content": {},
            "educational_tools": {},
        },
        "LICENSE": "",
        ".gitignore": "",
        "CONTRIBUTING.md": "",
    }
}

# Function to create the file tree
def create_file_tree(base_path, tree):
    try:
        for name, content in tree.items():
            path = os.path.join(base_path, name)
            if isinstance(content, dict):  # It's a directory
                os.makedirs(path, exist_ok=True)
                create_file_tree(path, content)  # Recursively create subdirectories and files
            else:  # It's a file
                with open(path, 'w') as f:
                    f.write(content)  # Create an empty file or write content if provided
        print(f"File tree created successfully in: {base_path}")
    except Exception as e:
        print(f"An error occurred while creating the file tree: {e}")

# Define the root directory for the project
root_dir = os.path.abspath("Qhy-Projects")

# Create the file tree
create_file_tree(root_dir, file_tree)
