import tkinter as tk
from tkinter import scrolledtext, messagebox
import subprocess
import os
import tempfile

class SQLEditor:
    def __init__(self, root):
        self.root = root
        self.root.title("SQL Syntax Editor")

        # Editor
        self.editor = scrolledtext.ScrolledText(root, wrap=tk.WORD, width=80, height=25)
        self.editor.pack(expand=True, fill='both')

        # Button Frame
        button_frame = tk.Frame(root)
        button_frame.pack(fill=tk.X)

        # Buttons
        tk.Button(button_frame, text="Check Syntax", command=self.check_syntax).pack(side=tk.LEFT, padx=5)
        tk.Button(button_frame, text="Clear", command=self.clear_editor).pack(side=tk.LEFT, padx=5)

        # Status Bar
        self.status = tk.Label(root, text="Ready", bd=1, relief=tk.SUNKEN, anchor=tk.W)
        self.status.pack(side=tk.BOTTOM, fill=tk.X)

        # Tool paths
        self.win_flex_path = r"C:\GnuWin32\bin\flex.exe"      ##Add your own File Path
        self.win_bison_path = r"C:\GnuWin32\bin\bison.exe"    ##Add your own File Path
        self.gcc_path = r"C:\msys64\ucrt64\bin\gcc.exe"       ##Add your own File Path

    def clear_editor(self):
        self.editor.delete(1.0, tk.END)
        self.status.config(text="Editor cleared")

    def check_syntax(self):
        sql_code = self.editor.get(1.0, tk.END).strip()
        if not sql_code:
            messagebox.showwarning("Empty", "Editor is empty!")
            return

        tmp_path = ""
        try:
            # Write code to temp file
            with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as tmp:
                tmp.write(sql_code)
                tmp_path = tmp.name

            # Compile parser if needed
            if not os.path.exists("parser.exe"):
                self.compile_parser()

            # Run parser
            result = subprocess.run(
                ["parser.exe", tmp_path],
                capture_output=True,
                text=True,
                cwd=os.getcwd(),
                timeout=5  # Avoid hanging
            )

            # Display result
            if result.returncode == 0:
                output = result.stdout.strip() or "SQL syntax is valid!"
                messagebox.showinfo("Success", output)
                self.status.config(text="Syntax OK")
            else:
                error_msg = result.stderr.strip() or result.stdout.strip() or "Unknown syntax error"
                messagebox.showerror("Error", error_msg)
                self.status.config(text="Syntax Error")

        except subprocess.TimeoutExpired:
            messagebox.showerror("Timeout", "Parser took too long to respond.")
            self.status.config(text="Timeout error")
        except Exception as e:
            messagebox.showerror("Error", f"Failed: {str(e)}")
            self.status.config(text="Execution failed")
        finally:
            if tmp_path and os.path.exists(tmp_path):
                os.remove(tmp_path)

    def compile_parser(self):
        try:
            subprocess.run([self.win_flex_path, "sql_lex.l"], check=True)
            subprocess.run([self.win_bison_path, "-d", "sql_yacc.y", "-o", "sql_yacc.tab.c"], check=True)
            subprocess.run([self.gcc_path, "-o", "parser", "sql_yacc.tab.c", "lex.yy.c", "-lfl"], check=True)
            self.status.config(text="Parser compiled successfully")
        except subprocess.CalledProcessError as e:
            raise Exception("Parser compilation failed.")

if __name__ == "__main__":
    root = tk.Tk()
    app = SQLEditor(root)
    root.mainloop()
