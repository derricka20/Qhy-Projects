from setuptools import setup, find_packages

setup(
    name="Qhy-Projects",
    version="0.1",
    author="Your Name",
    description="QhyNLP official projects repository.",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    packages=find_packages(),
    install_requires=[
        # List your dependencies here, e.g., "numpy", "pandas", etc.
    ],
    entry_points={
        "console_scripts": [
            "ddsv-cli=ddsv_module.cli:main"  # Add an entry point for any CLI tools
        ]
    },
    include_package_data=True,  # Include non-Python files specified in MANIFEST.in
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.7',
)
