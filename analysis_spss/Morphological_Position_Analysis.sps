* Encoding: UTF-8.

* ========================================================================
* SPSS Multi-Sheet Analysis Script
* ========================================================================
* Purpose: Import data from multiple Excel sheets and run GLM analysis
*          on each sheet, saving results as PDF and SPV files.
*
* Requirements:
*   - Excel file with sheets containing three columns:
*     "HairType" (String), "Base" (Numeric), and "Tip" (Numeric)
*   - First row must contain these column headers
*
* Output: 
*   - Analysis results displayed in SPSS Viewer
*   - PDF file for each sheet analysis
*   - SPV file for each sheet analysis
* ========================================================================

BEGIN PROGRAM Python.
import spss
import os
from tkinter import Tk, simpledialog
from tkinter.filedialog import askopenfilename, askdirectory

# ========================================================================
# Step 1: Setup and File Selection
# ========================================================================

# Hide the root Tkinter window (prevents empty window from appearing)
root = Tk()
root.withdraw()

# Prompt user to select the Excel file containing the data
file_path = askopenfilename(title="Select Excel file",
                            filetypes=[("Excel files", "*.xlsx")])

# Prompt user to select the folder where output files will be saved
output_folder = askdirectory(title="Select folder to save output files")

# ========================================================================
# Step 2: Process Multiple Sheets
# ========================================================================

# Check if both file and output folder were selected
if file_path and output_folder:
    # Prompt user to enter sheet names (comma-separated)
    sheet_names_input = simpledialog.askstring(
        "Sheet Names",
        "Enter sheet names separated by commas:\n(e.g., Thickness, CEC,CaS)"
    )
    
    if sheet_names_input:
        # Split the input into a list of sheet names and remove extra whitespace
        sheet_names = [name.strip() for name in sheet_names_input.split(',')]
        
        # ====================================================================
        # Step 3: Loop Through Each Sheet and Run Analysis
        # ====================================================================
        
        for i, sheet_name in enumerate(sheet_names):
            # Create unique dataset name for each sheet
            dataset_name = f"DataSet{i}"
            
            # Define output file paths (both SPV and PDF formats)
            output_spv = os.path.join(output_folder, f"{sheet_name}_Analysis.spv")
            output_pdf = os.path.join(output_folder, f"{sheet_name}_Analysis.pdf")
            
            # ================================================================
            # Step 3a: Import Data from Excel Sheet
            # ================================================================
            # Import data from the specified sheet with:
            #   - Full cell range
            #   - First row as variable names (headers)
            spss.Submit(f"""
GET DATA
  /TYPE=XLSX
  /FILE="{file_path}"
  /SHEET=name "{sheet_name}"
  /CELLRANGE=FULL
  /READNAMES=ON.
DATASET NAME {dataset_name} WINDOW=FRONT.
""")
            
            # ================================================================
            # Step 3b: Activate Dataset and Create Output Window
            # ================================================================
            # Activate the newly imported dataset
            # Create a new output window for this analysis
            spss.Submit(f"""
DATASET ACTIVATE {dataset_name}.

OUTPUT NEW NAME={dataset_name}_Output.
""")
            
            # ================================================================
            # Step 3c: Run GLM (General Linear Model) Analysis
            # ================================================================
            # GLM Repeated Measures Analysis:
            #   - Within-subject factor: Position (Base vs Tip)
            #   - Between-subject factor: HairType
            #   - Estimated marginal means for HairType*Position interaction
            spss.Submit(f"""
GLM Base Tip BY HairType
  /WSFACTOR=Position 2 Polynomial 
  /METHOD=SSTYPE(3)
  /EMMEANS=TABLES(HairType*Position) COMPARE(Position) ADJ(LSD)
  /EMMEANS=TABLES(HairType*Position) COMPARE(HairType) ADJ(LSD)
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=Position 
  /DESIGN=HairType.
""")
            
            # ================================================================
            # Step 3d: Save Output Files
            # ================================================================
            # Save the output in two formats:
            #   - SPV: SPSS Viewer format (can be reopened/edited in SPSS)
            #   - PDF: Portable document format (for sharing/archiving)
            spss.Submit(f"""
OUTPUT SAVE OUTFILE="{output_spv}".
OUTPUT EXPORT
  /CONTENTS EXPORT=ALL
  /PDF DOCUMENTFILE="{output_pdf}".
""")
            
            # Print confirmation message for each completed analysis
            print(f"Analysis completed for sheet: {sheet_name}")
            print(f"SPV output saved to: {output_spv}")
            print(f"PDF output saved to: {output_pdf}")
    else:
        # User cancelled or didn't enter any sheet names
        print("No sheet names entered. Analysis cancelled.")
else:
    # User cancelled file or folder selection
    print("No file selected. Analysis cancelled.")

END PROGRAM.
