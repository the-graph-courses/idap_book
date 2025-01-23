## Script to render plain markdown files. 
## Useful for accessible versions of chapters (HTML is hard for screen readers)
## This section obeys the _metadata.yml file, rather than the _quarto.yml file

import os
import subprocess
import shutil

# set the 

# copy the data folder to the md folder (overwrite if it exists)
shutil.copytree('../data', 'data', dirs_exist_ok=True)

# copy the local_settings.py file to the md folder (overwrite if it exists)
shutil.copy2('../local_settings.py', 'local_settings.py')

# List QMD files in the parent folder 
qmd_files = [f for f in os.listdir('..') if f.endswith('.qmd')]

# remove index.qmd, p_ai_LLM_functions_structured.qmd, quarto_dashboard_example.qmd, 00_book_summary.qmd, datasets.qmd
qmd_files = [f for f in qmd_files if f not in ['index.qmd', 'p_ai_LLM_functions_structured.qmd', 'quarto_dashboard_example.qmd', '00_book_summary.qmd', 'datasets.qmd']]

# Iterate through each file, moving it to the md folder and rendering it
for i in range(len(qmd_files)):
    qmd_file = qmd_files[i]
    print(f"Processing index {i} : {qmd_file}")
    
    # Copy file to md folder
    qmd_path = os.path.join('..', qmd_file)
    md_path = os.path.join(qmd_file)
    shutil.copy2(qmd_path, md_path)
    
    # Render the file in the md folder
    print(f"Rendering {qmd_file}")
    subprocess.run(["quarto", "render", md_path, "--to", "docusaurus-md"])

print("Rendering complete!")
