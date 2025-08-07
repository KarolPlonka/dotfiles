#!/usr/bin/env python3

import tkinter as tk
import tempfile
import subprocess
import os
from PIL import Image, ImageTk
from pathlib import Path

class ClipboardHistory:
    INIT_ENTRIES = 20  # Maximum number of entries to display
    WINDOW_SIZE = (700, 500)  # Default window size
    THUMBNAIL_SIZE = (100, 100)  # Size for image thumbnails
    GPASTE_IMAGE_DIR = os.path.expanduser("~/.local/share/gpaste/images")

    def __init__(self):
        self.root = tk.Tk()
        self.root.geometry(f'{self.WINDOW_SIZE[0]}x{self.WINDOW_SIZE[1]}')
        self.root.title("Clipboard History")
        self.root.configure(bg='#2b2b2b')
        
        self.root.wm_attributes('-type', 'splash')
        
        # Center the window on screen
        self.root.update_idletasks()
        width = self.root.winfo_width()
        height = self.root.winfo_height()
        x = (self.root.winfo_screenwidth() // 2) - (width // 2)
        y = (self.root.winfo_screenheight() // 2) - (height // 2)
        self.root.geometry(f'{width}x{height}+{x}+{y}')
        
        # Get clipboard history first
        self.clipboard_entries = self._get_clipboard_history()  # Store the actual text content
        self.filtered_entries = self.clipboard_entries.copy()  # Filtered text content
        self.filtered_indices = list(range(len(self.clipboard_entries)))
        self.current = 0
        self.search_mode = False
        self.info_panel_visible = False
        self.search_text = ""
        self.image_refs = []  # Keep references to prevent garbage collection
        self.entry_widgets = []  # Store widget references
        
        # Create main container frame
        self.main_container = tk.Frame(self.root, bg='#2b2b2b')
        self.main_container.pack(fill=tk.BOTH, expand=True)
        
        # Create left frame for the list
        self.left_frame = tk.Frame(self.main_container, bg='#2b2b2b')
        self.left_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        # Create a canvas for scrolling (no scrollbar)
        self.canvas = tk.Canvas(self.left_frame, bg='#2b2b2b', highlightthickness=0)
        self.scrollable_frame = tk.Frame(self.canvas, bg='#2b2b2b')
        
        self.scrollable_frame.bind(
            "<Configure>",
            lambda _: self.canvas.configure(scrollregion=self.canvas.bbox("all"))
        )
        
        self.canvas.create_window((0, 0), window=self.scrollable_frame, anchor="nw")
        
        # Pack canvas only (no scrollbar)
        self.canvas.pack(side="top", fill="both", expand=True, padx=10, pady=(10, 5))
        
        # Create search frame at the bottom (hidden by default)
        self.search_frame = tk.Frame(self.left_frame, bg='#1b1b1b', height=30)
        self.search_label = tk.Label(
            self.search_frame,
            text="Search: ",
            font=('Monospace', 10),
            bg='#1b1b1b',
            fg='#00ff00'
        )
        self.search_label.pack(side=tk.LEFT, padx=5)
        
        self.search_display = tk.Label(
            self.search_frame,
            text="",
            font=('Monospace', 10),
            bg='#1b1b1b',
            fg='white',
            anchor='w'
        )
        self.search_display.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=5)
        
        # Create right frame for info panel (hidden by default)
        self.right_frame = tk.Frame(self.main_container, bg='#1e1e1e', width=400)
        
        # Add separator
        self.separator = tk.Frame(self.right_frame, bg='#4a4a4a', width=2)
        self.separator.pack(side=tk.LEFT, fill=tk.Y)
        
        # Create info content area
        self.info_content = tk.Frame(self.right_frame, bg='#1e1e1e')
        self.info_content.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Add frame for image preview in info panel
        self.info_image_frame = tk.Frame(self.info_content, bg='#1e1e1e')
        self.info_image_frame.pack(side=tk.TOP, fill=tk.X, pady=(0, 10))
        
        self.info_image_label = tk.Label(self.info_image_frame, bg='#1e1e1e')
        self.info_image_label.pack()
        
        # Add text widget for info display
        self.info_text = tk.Text(
            self.info_content,
            font=('Monospace', 11),
            bg='#1e1e1e',
            fg='white',
            wrap=tk.WORD,
            padx=10,
            pady=10,
            insertbackground='white',
            selectbackground='#4a4a4a',
            selectforeground='#00ff00'
        )
        
        # Add info label at the bottom
        self.info_label = tk.Label(
            self.info_content,
            text="",
            font=('Monospace', 9),
            bg='#1e1e1e',
            fg='#888888'
        )
        
        # Pack info widgets
        self.info_label.pack(side=tk.BOTTOM, fill=tk.X, pady=(5, 0))
        self.info_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        # Create labels for each clipboard entry
        self.create_entry_widgets()
        
        # Key bindings
        self.root.bind('<Down>', lambda _: self.move_down())
        self.root.bind('<Up>', lambda _: self.move_up())
        self.root.bind('<Return>', lambda _: self.copy_and_exit())
        self.root.bind('<Escape>', lambda _: self.exit_search() if self.search_mode else self.root.quit())
        self.root.bind('<Control-c>', lambda _: self.exit_search() if self.search_mode else self.root.quit())
        self.root.bind('<Control-j>', lambda _: self.move_down())
        self.root.bind('<Control-k>', lambda _: self.move_up())
        self.root.bind('<Control-e>', lambda _: self.edit_in_neovim())
        self.root.bind('<Control-i>', lambda _: self.toggle_info_panel())
        self.root.bind('<Control-p>', lambda _: self.copy_image_path_and_quit())
        self.root.bind('<Control-y>', lambda _: self.copy_and_exit())
        self.bind_single_letter_keys()
        
        # Number key bindings for quick selection (1-9)
        for i in range(1, 10):
            self.root.bind(str(i), lambda _, idx=i-1: self.select_and_copy(idx) if not self.search_mode else None)
        
        # Mouse wheel scrolling
        self.canvas.bind_all("<MouseWheel>", self._on_mousewheel)
        self.canvas.bind_all("<Button-4>", self._on_mousewheel)
        self.canvas.bind_all("<Button-5>", self._on_mousewheel)
        
        self.root.focus_force()


    def copy_image_path_and_quit(self):
        """Copy the image path to clipboard if the current selection is an image"""
        if 0 <= self.current < len(self.filtered_entries):
            text = self.filtered_entries[self.current]
            
            # Check if it's an image
            if self.is_image_path(text):
                path_str = text.strip()
                
                # Copy the path to clipboard
                try:
                    subprocess.run(['xclip', '-selection', 'clipboard'], 
                                  input=path_str.encode(), check=True)
                    
                except subprocess.CalledProcessError:
                    print("Error: Could not copy path to clipboard")
                except FileNotFoundError:
                    print("Error: xclip not found. Please install xclip")

                self.root.quit()


    def is_image_path(self, text):
        """Check if the text is a path to a GPaste image"""
        if not text or not isinstance(text, str):
            return False
        
        # Check if it contains the GPaste images directory
        if self.GPASTE_IMAGE_DIR not in text:
            return False
        
        # Check if it has an image extension
        image_extensions = {'.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp', '.ico'}
        path = Path(text.strip())
        return path.suffix.lower() in image_extensions


    def load_thumbnail(self, image_path):
        """Load and create a thumbnail from an image path"""
        try:
            path = Path(image_path.strip())
            if path.exists():
                img = Image.open(path)
                img.thumbnail(self.THUMBNAIL_SIZE, Image.Resampling.LANCZOS)
                return ImageTk.PhotoImage(img)
            return None
        except Exception as e:
            print(f"Error loading image {image_path}: {e}")
            return None

    
    def bind_single_letter_keys(self):
        self.root.bind('j', lambda _: self.move_down() if not self.search_mode else None)
        self.root.bind('k', lambda _: self.move_up() if not self.search_mode else None)
        self.root.bind('e', lambda _: self.edit_in_neovim() if not self.search_mode else None)
        self.root.bind('i', lambda _: self.toggle_info_panel() if not self.search_mode else None)
        self.root.bind('/', lambda _: self.enter_search() if not self.search_mode else None)
        self.root.bind('q', lambda _: self.root.quit())
        self.root.bind('p', lambda _: self.copy_image_path_and_quit() if not self.search_mode else None)
        self.root.bind('y', lambda _: self.copy_and_exit())


    def unbind_single_letter_keys(self):
        self.root.unbind('e')
        self.root.unbind('i')
        self.root.unbind('/')
        self.root.unbind('q')
        self.root.unbind('j')
        self.root.unbind('k')
        self.root.unbind('p')
        self.root.unbind('y')
    

    def toggle_info_panel(self):
        """Toggle the info panel on the right side"""
        if self.info_panel_visible:
            self.hide_info_panel()
        else:
            self.show_info_panel()
    

    def show_info_panel(self):
        """Show the info panel with the selected clipboard entry"""
        if 0 <= self.current < len(self.filtered_entries) and not self.info_panel_visible:
            self.info_panel_visible = True
            
            # Expand window to the right
            current_width = self.root.winfo_width()
            current_height = self.root.winfo_height()
            current_x = self.root.winfo_x()
            current_y = self.root.winfo_y()
            
            new_width = current_width + 400
            self.root.geometry(f'{new_width}x{current_height}+{current_x}+{current_y}')
            
            # Show the right frame
            self.right_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True)
            
            # Update info content
            self.update_info_panel()
    

    def hide_info_panel(self):
        """Hide the info panel"""
        if self.info_panel_visible:
            self.info_panel_visible = False
            
            # Hide the right frame
            self.right_frame.pack_forget()
            
            # Shrink window back to original size
            current_height = self.root.winfo_height()
            current_x = self.root.winfo_x()
            current_y = self.root.winfo_y()
            
            self.root.geometry(f'{self.WINDOW_SIZE[0]}x{current_height}+{current_x}+{current_y}')
    

    def update_info_panel(self):
        """Update the content of the info panel"""
        if self.info_panel_visible and 0 <= self.current < len(self.filtered_entries):
            text = self.filtered_entries[self.current]
            
            # Check if it's an image
            if self.is_image_path(text):
                path = Path(text.strip())
                if path.exists():
                    # Show larger image preview
                    try:
                        img = Image.open(path)
                        # Scale to fit in info panel
                        max_size = (350, 300)
                        img.thumbnail(max_size, Image.Resampling.LANCZOS)
                        photo = ImageTk.PhotoImage(img)
                        self.info_image_label.configure(image=photo)
                        setattr(self.info_image_label, 'image', photo)  # Keep reference
                        self.info_image_frame.pack(side=tk.TOP, fill=tk.X, pady=(0, 10))
                        
                        # Show image info in text
                        orig_img = Image.open(path)
                        info_text = f"Image: {path.name}\n"
                        info_text += f"Dimensions: {orig_img.width}x{orig_img.height}\n"
                        info_text += f"Format: {orig_img.format}\n"
                        info_text += f"Mode: {orig_img.mode}\n"
                        info_text += f"Path: {path}"
                        
                        self.info_text.configure(state='normal')
                        self.info_text.delete('1.0', tk.END)
                        self.info_text.insert('1.0', info_text)
                        self.info_text.configure(state='disabled')
                    except Exception as e:
                        self.info_image_frame.pack_forget()
                        self.info_text.configure(state='normal')
                        self.info_text.delete('1.0', tk.END)
                        self.info_text.insert('1.0', f"Error loading image: {e}\n\nPath: {path}")
                        self.info_text.configure(state='disabled')
                else:
                    self.info_image_frame.pack_forget()
                    self.info_text.configure(state='normal')
                    self.info_text.delete('1.0', tk.END)
                    self.info_text.insert('1.0', f"Image file not found:\n{path}")
                    self.info_text.configure(state='disabled')
            else:
                # Hide image frame for text entries
                self.info_image_frame.pack_forget()
                
                # Clear and update text
                self.info_text.configure(state='normal')
                self.info_text.delete('1.0', tk.END)
                self.info_text.insert('1.0', text)
                self.info_text.configure(state='disabled')
            
            # Update info label
            entry_num = self.filtered_indices[self.current] + 1
            total_entries = len(self.clipboard_entries)
            
            if self.is_image_path(text):
                self.info_label.config(text=f"Entry {entry_num} of {total_entries} | Image | Ctrl+P: copy path")
            else:
                char_count = len(text)
                line_count = text.count('\n') + 1
                self.info_label.config(text=f"Entry {entry_num} of {total_entries} | {char_count} characters | {line_count} lines")
    

    def create_entry_widgets(self):
        """Create or recreate entry widgets based on filtered options"""
        # Clear existing widgets
        for widget in self.scrollable_frame.winfo_children():
            widget.destroy()
        
        self.entry_widgets = []
        self.image_refs = []  # Clear image references
        
        for i, (option_idx, option) in enumerate(zip(self.filtered_indices, self.filtered_entries)):
            # Create a frame for each entry
            entry_frame = tk.Frame(self.scrollable_frame, bg='#2b2b2b')
            entry_frame.pack(fill=tk.X, pady=2)
            
            # Add line number
            num_label = tk.Label(
                entry_frame,
                text=f"{option_idx + 1}. ",
                font=('Monospace', 10),
                bg='#2b2b2b',
                fg='white',
                anchor='w'
            )
            num_label.pack(side=tk.LEFT, padx=(10, 5))
            
            # Check if it's an image
            if self.is_image_path(option):
                path = Path(option.strip())
                if path.exists():
                    # Try to load and display thumbnail
                    thumbnail = self.load_thumbnail(option)
                    if thumbnail:
                        self.image_refs.append(thumbnail)  # Keep reference
                        img_label = tk.Label(
                            entry_frame,
                            image=thumbnail,
                            bg='#2b2b2b'
                        )

                        img_label.pack(side=tk.LEFT, padx=5)
                        
                        # Add image info (size, dims, extension)
                        try:
                            # Get file size
                            size_bytes = path.stat().st_size
                            if size_bytes < 1024:
                                size_str = f"{size_bytes}B"
                            elif size_bytes < 1024 * 1024:
                                size_str = f"{size_bytes / 1024:.1f}KB"
                            else:
                                size_str = f"{size_bytes / (1024 * 1024):.1f}MB"
                            
                            # Get image dimensions
                            img = Image.open(path)
                            width, height = img.size
                            
                            # Get extension (without dot)
                            ext = path.suffix[1:].upper()
                            
                            # Create a container frame for the info labels
                            info_frame = tk.Frame(entry_frame, bg='#2b2b2b')
                            info_frame.pack(side=tk.LEFT, padx=5)
                            
                            # Create labels for each piece of info
                            dimension_label = tk.Label(
                                info_frame,
                                text=f"{width}x{height}",
                                font=('Monospace', 10),
                                bg='#2b2b2b',
                                fg='white',
                                anchor='w'
                            )
                            dimension_label.pack(anchor='w')
                            
                            size_label = tk.Label(
                                info_frame,
                                text=size_str,
                                font=('Monospace', 10),
                                bg='#2b2b2b',
                                fg='white',
                                anchor='w'
                            )
                            size_label.pack(anchor='w')
                            
                            ext_label = tk.Label(
                                info_frame,
                                text=ext,
                                font=('Monospace', 10),
                                bg='#2b2b2b',
                                fg='white',
                                anchor='w'
                            )
                            ext_label.pack(anchor='w')
                            
                        except Exception:
                            info_label = tk.Label(
                                entry_frame,
                                text="Could not retrieve\nimage info",
                                font=('Monospace', 10),
                                bg='#2b2b2b',
                                fg='white',
                                anchor='w'
                            )
                            info_label.pack(side=tk.LEFT, padx=5)
                else:
                    # File doesn't exist - show path in orange
                    text_label = tk.Label(
                        entry_frame,
                        text=f"[Missing Image] {option[:60]}..." if len(option) > 60 else f"[Missing Image] {option}",
                        font=('Monospace', 10),
                        bg='#2b2b2b',
                        fg='orange',
                        anchor='w'
                    )
                    text_label.pack(side=tk.LEFT, padx=5)
            else:
                # Regular text entry
                display_text = option.replace('\n', ' ')[:80] + "..." if len(option) > 80 else option.replace('\n', ' ')
                
                # Highlight search matches if in search mode
                if self.search_mode and self.search_text:
                    lower_display = display_text.lower()
                    lower_search = self.search_text.lower()
                    if lower_search in lower_display:
                        # Find and highlight the search text
                        start = lower_display.find(lower_search)
                        before = display_text[:start]
                        match = display_text[start:start + len(self.search_text)]
                        after = display_text[start + len(self.search_text):]
                        
                        if before:
                            tk.Label(
                                entry_frame,
                                text=before,
                                font=('Monospace', 10),
                                bg='#2b2b2b',
                                fg='white',
                                anchor='w'
                            ).pack(side=tk.LEFT)
                        
                        tk.Label(
                            entry_frame,
                            text=match,
                            font=('Monospace', 10, 'bold'),
                            bg='#2b2b2b',
                            fg='yellow',
                            anchor='w'
                        ).pack(side=tk.LEFT)
                        
                        if after:
                            tk.Label(
                                entry_frame,
                                text=after,
                                font=('Monospace', 10),
                                bg='#2b2b2b',
                                fg='white',
                                anchor='w'
                            ).pack(side=tk.LEFT)
                    else:
                        # No match, show normal text
                        text_label = tk.Label(
                            entry_frame,
                            text=display_text,
                            font=('Monospace', 10),
                            bg='#2b2b2b',
                            fg='white',
                            anchor='w'
                        )
                        text_label.pack(side=tk.LEFT, padx=5)
                else:
                    # Normal text (no search highlighting)
                    text_label = tk.Label(
                        entry_frame,
                        text=display_text,
                        font=('Monospace', 10),
                        bg='#2b2b2b',
                        fg='white',
                        anchor='w'
                    )
                    text_label.pack(side=tk.LEFT, padx=5)
            
            self.entry_widgets.append(entry_frame)
        
        if not self.entry_widgets and self.search_mode:
            # Show "no results" message
            label = tk.Label(
                self.scrollable_frame,
                text="No matches found",
                font=('Monospace', 10, 'italic'),
                bg='#2b2b2b',
                fg='#888888',
                anchor='center',
                padx=10,
                pady=20
            )
            label.pack(fill=tk.X)
            self.entry_widgets.append(label)
        
        self.update_highlight()


    
    def enter_search(self):
        """Enter search mode"""
        self.search_mode = True
        self.search_text = ""
        self.search_frame.pack(side=tk.BOTTOM, fill=tk.X, padx=10, pady=(5, 10))
        self.search_display.config(text=self.search_text + "_")
        self.unbind_single_letter_keys()
        
        # Bind keys for search mode
        self.root.bind('<Key>', self.handle_search_key)

    
    def exit_search(self):
        """Exit search mode and restore normal view"""
        self.search_mode = False
        self.search_text = ""
        self.search_frame.pack_forget()
        self.root.unbind('<Key>')
        
        # Reset to show all items
        self.filtered_entries = self.clipboard_entries.copy()
        self.filtered_indices = list(range(len(self.clipboard_entries)))
        self.current = 0
        self.create_entry_widgets()
        self.ensure_visible()
        self.bind_single_letter_keys()

    
    def handle_search_key(self, event):
        """Handle key presses in search mode"""
        if not self.search_mode:
            return
        
        if event.keysym == 'BackSpace':
            if self.search_text:
                self.search_text = self.search_text[:-1]
                self.update_search()
        elif event.keysym in ('Return', 'Escape'):
            # These are handled by the main bindings
            return
        elif event.keysym == 'c' and event.state & 0x4:  # Ctrl+C
            self.exit_search()
            return
        elif len(event.char) == 1 and event.char.isprintable():
            self.search_text += event.char
            self.update_search()

    
    def update_search(self):
        """Update the search results"""
        self.search_display.config(text=self.search_text + "_")
        
        if not self.search_text:
            # Show all items if search is empty
            self.filtered_entries = self.clipboard_entries.copy()
            self.filtered_indices = list(range(len(self.clipboard_entries)))
        else:
            # Filter items based on search text
            self.filtered_entries = []
            self.filtered_indices = []
            
            search_lower = self.search_text.lower()
            for i, entry in enumerate(self.clipboard_entries):
                if search_lower in entry.lower():
                    self.filtered_entries.append(entry)
                    self.filtered_indices.append(i)
        
        self.current = 0
        self.create_entry_widgets()
        self.ensure_visible()

    
    def _get_clipboard_history(self):
        try:
            # Run gpaste-client to get clipboard history
            result = subprocess.run(
                ['gpaste-client', 'history', '--raw', '--zero'],
                capture_output=True,
                text=True,
                check=True
            )
            
            # Split by NUL character and filter empty entries
            entries = result.stdout.split('\0')[:self.INIT_ENTRIES]
            entries = [entry.strip() for entry in entries if entry.strip()]
            
            # Return entries or default if empty
            return entries if entries else ["No clipboard history found"]
            
        except subprocess.CalledProcessError:
            # If gpaste-client fails, return error message
            return ["Error: Could not access GPaste history"]
        except FileNotFoundError:
            # If gpaste-client is not installed
            return ["Error: gpaste-client not found. Please install GPaste"]
    

    def _on_mousewheel(self, event):
        if event.num == 4 or event.delta > 0:
            self.canvas.yview_scroll(-1, "units")
        elif event.num == 5 or event.delta < 0:
            self.canvas.yview_scroll(1, "units")
    

    def move_down(self):
        if len(self.entry_widgets) > 0 and self.filtered_entries:
            self.current = (self.current + 1) % len(self.entry_widgets)
            self.update_highlight()
            self.ensure_visible()
            if self.info_panel_visible:
                self.update_info_panel()
    

    def move_up(self):
        if len(self.entry_widgets) > 0 and self.filtered_entries:
            self.current = (self.current - 1) % len(self.entry_widgets)
            self.update_highlight()
            self.ensure_visible()
            if self.info_panel_visible:
                self.update_info_panel()

    
    def ensure_visible(self):
        """Scroll the canvas to ensure the current item is visible"""
        if not self.entry_widgets or not self.filtered_entries:
            return
            
        # Update the canvas to get accurate positions
        self.canvas.update_idletasks()
        
        # Get the current widget
        current_widget = self.entry_widgets[self.current]
        
        # Get widget position relative to canvas
        widget_top = current_widget.winfo_y()
        widget_bottom = widget_top + current_widget.winfo_height()
        
        # Get canvas viewport
        canvas_height = self.canvas.winfo_height()
        canvas_top = self.canvas.canvasy(0)
        canvas_bottom = self.canvas.canvasy(canvas_height)
        
        # Check if widget is outside viewport
        if widget_top < canvas_top:
            # Scroll up to show the widget at the top
            self.canvas.yview_moveto(widget_top / self.scrollable_frame.winfo_height())
        elif widget_bottom > canvas_bottom:
            # Scroll down to show the widget at the bottom
            # Calculate position to show widget at bottom of viewport
            target_top = widget_bottom - canvas_height
            self.canvas.yview_moveto(target_top / self.scrollable_frame.winfo_height())
    

    def update_highlight(self):
        for i, widget in enumerate(self.entry_widgets):
            if i == self.current:
                self._set_widget_colors(widget, bg='#4a4a4a', fg='#00ff00')
            else:
                self._set_widget_colors(widget, bg='#2b2b2b', fg='white')
    

    def _set_widget_colors(self, widget, bg, fg):
        """Recursively set colors for a widget and its children"""
        if isinstance(widget, tk.Frame):
            widget.configure(bg=bg)
            for child in widget.winfo_children():
                if isinstance(child, tk.Label):
                    # Preserve yellow color for search matches and orange for missing images
                    current_fg = child.cget('fg')
                    if current_fg in ['yellow', 'orange']:
                        child.configure(bg=bg)
                    else:
                        child.configure(bg=bg, fg=fg)
        else:
            widget.configure(bg=bg, fg=fg)
    

    def select_and_copy(self, index):
        if 0 <= index < len(self.entry_widgets) and self.filtered_entries:
            self.current = index
            self.update_highlight()
            self.ensure_visible()
            self.root.after(100, self.copy_and_exit)  # Small delay for visual feedback

    
    def edit_in_neovim(self):
        """Open the selected clipboard entry in Neovim"""
        if 0 <= self.current < len(self.filtered_entries):
            text = self.filtered_entries[self.current]
            
            # Check if it's an image
            if self.is_image_path(text):
                path = Path(text.strip())
                if path.exists():
                    # Open image with default image viewer
                    try:
                        subprocess.Popen(['xdg-open', str(path)])
                    except Exception as e:
                        print(f"Error opening image: {e}")
                return
            
            # For text, create a temporary file and open in neovim
            with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.txt') as f:
                f.write(text)
                temp_file = f.name
            
            try:
                # Open a new terminal window with neovim
                # Using common terminal emulators - try them in order
                terminals = [
                    ['gnome-terminal', '--', 'nvim', temp_file],
                    ['konsole', '-e', 'nvim', temp_file],
                    ['xterm', '-e', 'nvim', temp_file],
                    ['alacritty', '-e', 'nvim', temp_file],
                    ['kitty', 'nvim', temp_file],
                ]
                
                for terminal_cmd in terminals:
                    try:
                        subprocess.Popen(terminal_cmd)
                        break
                    except FileNotFoundError:
                        continue
                else:
                    # If no terminal worked, try xdg-open as fallback
                    subprocess.Popen(['xdg-open', temp_file])
                
            except Exception as e:
                print(f"Error opening Neovim: {e}")
    

    def copy_and_exit(self):
        if 0 <= self.current < len(self.filtered_entries):
            text = self.filtered_entries[self.current]
            
            # Check if it's an image
            if self.is_image_path(text):
                path = Path(text.strip())
                if path.exists():
                    # Copy the image file to clipboard
                    try:
                        # Use xclip to copy image
                        subprocess.run(['xclip', '-selection', 'clipboard', '-t', 'image/png', '-i', str(path)], 
                                      check=True)
                    except subprocess.CalledProcessError:
                        print("Error: Could not copy image to clipboard")
                    except FileNotFoundError:
                        print("Error: xclip not found. Please install xclip")
                else:
                    print(f"Error: Image file not found: {path}")
            else:
                # Copy text to clipboard
                try:
                    subprocess.run(['xclip', '-selection', 'clipboard'], 
                                  input=text.encode(), check=True)
                except subprocess.CalledProcessError:
                    print("Error: Could not copy to clipboard")
                except FileNotFoundError:
                    print("Error: xclip not found. Please install xclip")
        
        self.root.quit()
    

    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    app = ClipboardHistory()
    app.run()
