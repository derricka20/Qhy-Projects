using System;
using System.Collections.Generic;
using System.IO;

class FileTreeBuilder
{
    // Define the file tree structure with content for files
    static readonly Dictionary<string, object> fileTree = new Dictionary<string, object>
    {
        { "DDSV", new Dictionary<string, object>
            {
                { "src", new Dictionary<string, object>
                    {
                        { "ddsv_core.pl", "#!/usr/bin/perl\n\n# Core Perl script for DDSV\nprint \"DDSV Core Loaded!\\n\";" },
                        { "linking_system.pl", "#!/usr/bin/perl\n\n# Dynamic linking system implementation\nprint \"Linking System Initialized\\n\";" },
                        { "text_manipulation.pl", "#!/usr/bin/perl\n\n# Perl text manipulation script\nprint \"Text Manipulation Module Running\\n\";" },
                        { "utils", new Dictionary<string, object>
                            {
                                { "data_helpers.pl", "#!/usr/bin/perl\n\n# Helper functions for data handling\nprint \"Data Helpers Ready\\n\";" },
                                { "analytics_tools.pl", "#!/usr/bin/perl\n\n# Analytics and insights tools\nprint \"Analytics Tools Engaged\\n\";" }
                            }
                        }
                    }
                },
                { "data", new Dictionary<string, object>
                    {
                        { "sample_data.txt", "Sample data for DDSV testing and debugging." }
                    }
                },
                { "extensions", new Dictionary<string, object>
                    {
                        { "cross_platform", new Dictionary<string, object>
                            {
                                { "aws_integration.pl", "#!/usr/bin/perl\n\n# AWS Integration Module\nprint \"AWS Integration Active\\n\";" }
                            }
                        },
                        { "gui", new Dictionary<string, object>
                            {
                                { "web_gui_design.pl", "#!/usr/bin/perl\n\n# GUI design for DDSV\nprint \"Web GUI Initialized\\n\";" }
                            }
                        },
                        { "machine_learning", new Dictionary<string, object>() }
                    }
                },
                { "tests", new Dictionary<string, object>
                    {
                        { "core_tests.pl", "#!/usr/bin/perl\n\n# Core tests for DDSV\nprint \"Running Core Tests\\n\";" },
                        { "integration_tests.pl", "#!/usr/bin/perl\n\n# Integration tests for DDSV\nprint \"Running Integration Tests\\n\";" }
                    }
                }
            }
        },
        { "docs", new Dictionary<string, object>
            {
                { "README.md", "# Qhy-Projects\n\nThis repository contains all official projects related to QhyNLP." },
                { "ddsv_design.md", "## DDSV Design and Architecture\n\nDetailed explanation of DDSV design principles." },
                { "extensions_docs.md", "## Extensions Documentation\n\nDocumentation for DDSV extensions." },
                { "api_docs", new Dictionary<string, object>
                    {
                        { "authentication_api.md", "## Authentication API Documentation\n\nDetails about the authentication API for DDSV." }
                    }
                }
            }
        },
        { "examples", new Dictionary<string, object>
            {
                { "chatbot", new Dictionary<string, object>
                    {
                        { "chatbot_example.pl", "#!/usr/bin/perl\n\n# Example chatbot implementation using DDSV\nprint \"Chatbot Running\\n\";" }
                    }
                },
                { "dynamic_content", new Dictionary<string, object>() },
                { "educational_tools", new Dictionary<string, object>() }
            }
        },
        { "LICENSE", "MIT License\n\nThis project is licensed under the MIT License." },
        { ".gitignore", "# Ignore files and folders\n*.tmp\nbuild/" },
        { "CONTRIBUTING.md", "# Contributing to Qhy-Projects\n\nThank you for your interest in contributing!" }
    };

    static void Main(string[] args)
    {
        string rootDirectory = Path.Combine(Directory.GetCurrentDirectory(), "Qhy-Projects");

        try
        {
            CreateFileTree(rootDirectory, fileTree);
            Console.WriteLine($"File tree created and populated successfully in: {rootDirectory}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"An error occurred: {ex.Message}");
        }
    }

    // Recursive method to create the file tree
    static void CreateFileTree(string basePath, Dictionary<string, object> tree)
    {
        foreach (var item in tree)
        {
            string path = Path.Combine(basePath, item.Key);

            if (item.Value is Dictionary<string, object>) // It's a directory
            {
                Directory.CreateDirectory(path); // Create the directory
                CreateFileTree(path, (Dictionary<string, object>)item.Value); // Recurse into subdirectories
            }
            else // It's a file
            {
                try
                {
                    File.WriteAllText(path, (string)item.Value); // Create the file with content
                    Console.WriteLine($"Created file: {path}");
                }
                catch (Exception e)
                {
                    Console.WriteLine($"Failed to create file: {path} - Error: {e.Message}");
                }
            }
        }
    }
}
