-- Define the file tree structure
local file_tree = {
    ["DDSV"] = {
        ["src"] = {
            ["ddsv_core.pl"] = "",
            ["linking_system.pl"] = "",
            ["text_manipulation.pl"] = "",
            ["utils"] = {
                ["data_helpers.pl"] = "",
                ["analytics_tools.pl"] = ""
            }
        },
        ["data"] = {},
        ["extensions"] = {
            ["cross_platform"] = {},
            ["gui"] = {},
            ["machine_learning"] = {}
        },
        ["tests"] = {
            ["core_tests.pl"] = "",
            ["integration_tests.pl"] = ""
        }
    },
    ["docs"] = {
        ["README.md"] = "",
        ["ddsv_design.md"] = "",
        ["extensions_docs.md"] = "",
        ["api_docs"] = {}
    },
    ["examples"] = {
        ["chatbot"] = {},
        ["dynamic_content"] = {},
        ["educational_tools"] = {}
    },
    ["LICENSE"] = "",
    [".gitignore"] = "",
    ["CONTRIBUTING.md"] = ""
}

-- Function to create the file tree recursively
local function create_file_tree(base_path, tree)
    for name, content in pairs(tree) do
        local path = base_path .. "/" .. name
        if type(content) == "table" then
            -- Create a directory
            os.execute("mkdir -p " .. path) -- Use `mkdir -p` for recursive directory creation
            create_file_tree(path, content) -- Recursively create subdirectories
        else
            -- Create a file
            local file = io.open(path, "w")
            if file then
                file:write(content) -- Add content if needed (optional)
                file:close()
            else
                print("Failed to create file: " .. path)
            end
        end
    end
end

-- Define the root directory for the project
local root_dir = "Qhy-Projects"

-- Call the function to create the file tree
create_file_tree(root_dir, file_tree)

print("File tree created successfully in: " .. root_dir)
