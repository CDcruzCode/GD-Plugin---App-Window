##A helper class for useful common functions
@tool
class_name CDUtils
extends Node

####TABLE OF CONTENTS####

##SCRIPT FUNCTIONS##
##-delay
##-is_bool

##SCREEN SPACE FUNCTIONS##
##-screen_center_node
##-screen_center_bottom_node

##NODE FUNCTIONS##
##-delete_all_children
##-get_children_in_group
##-children_in_group_count
##-delete_all_group_children
##-get_node_by_name
#Button#
##-set_option_by_text

##DIRECTORY/FILE FUNCTIONS##
##-dir_exists
##-file_exists
##-create_dir
##-deep_copy_dir
##-deep_remove_dir
##-list_folders_in_dir
##-save_text_file
##-delete_file
##-load_file_as_string
##-copy_file

##STRING FUNCTIONS##
##-remove_nums
##-remove_letters
##-remove_symbols
##-make_filename_unique
##-make_dir_unique
##-remove_after_phrase
##-remove_before_phrase
##-number_suffix
##-get_drive_and_last_folders
##-is_valid_hex
##-format_uuid

##MATH FUNCTIONS##
##-approx_equal
##-round_places
##-scale_num_to_range

##COLOUR FUNCTIONS##
##-contract_text

##AUDIO FUNCTIONS##
##-cents_to_scale
##-load_mp3

####

####
#SCRIPT FUNCTIONS
####

## Asynchronously delays execution for a given number of seconds.
## @param tree: The SceneTree instance (e.g. get_tree() from a Node).
## @param time: The delay duration in seconds (must be non-negative).
static func delay(tree: SceneTree, time: float = 1.0) -> void:
	if time < 0:
		push_error("delay: time must be non-negative, got %f" % time)
		return
	await tree.create_timer(time).timeout

## Converts a string to a boolean value. Only "true" (case-insensitive) returns `true`, 
## all other values return `false`.
##
## - `st`: The string to convert to a boolean.
## - Returns: `true` if the string is "true" (case-insensitive), `false` otherwise.
static func is_bool(st: String) -> bool:
	# Convert the string to lowercase for case-insensitive comparison
	var lower_str: String = st.strip_edges().to_lower()
	
	# Return true if the string is "true", false otherwise
	return lower_str == "true"



####
#SCREEN SPACE FUNCTIONS
####

## Returns the top-left position (as a Vector2i) to center a node of the given size on the screen.
## @param node_size: The size of the node as a Vector2i.
## @return: A Vector2i representing the position that will center the node.
static func screen_center_node(node_size: Vector2i) -> Vector2i:
	var window_size: Vector2 = DisplayServer.window_get_size()
	var screen_center: Vector2 = window_size / 2.0
	var half_node: Vector2 = Vector2(node_size.x, node_size.y) / 2.0
	return Vector2i( int(screen_center.x - half_node.x), int(screen_center.y - half_node.y) )

## Calculates the position to center a node horizontally and position it near the bottom of the window.
## @param node_size: The size of the node as a Vector2i.
## @param spacing: The distance in pixels from the bottom edge of the window (default is 10 pixels).
## @return: A Vector2i representing the top-left position to place the node.
static func screen_center_bottom_node(node_size: Vector2i, spacing: int = 10) -> Vector2i:
	var window_size: Vector2i = DisplayServer.window_get_size()
	var x_position: int = (window_size.x - node_size.x) / 2
	var y_position: int = window_size.y - node_size.y - spacing
	return Vector2i(x_position, y_position)


####
#SCENE FUNCTIONS
####

####
#NODE FUNCTIONS
####

## Deletes all direct children of the given node.
## Each child is queued for deletion using queue_free().
static func delete_all_children(node: Node) -> void:
	if not node:
		push_error("[CDUtils] delete_all_children: Provided node is null.")
		return
	for child: Node in node.get_children():
		child.queue_free()

## Retrieves all direct children of the given parent node that are members of the specified group.
## @param parent: The parent Node whose children will be checked.
## @param group: The name of the group to check membership against.
## @return: An Array of Nodes that are direct children of the parent and belong to the specified group.
static func get_children_in_group(parent: Node, group: StringName) -> Array[Node]:
	var group_children: Array[Node] = []
	if group == "":
		return group_children  # Early exit if group name is empty

	for child in parent.get_children():
		if child.is_in_group(group):
			group_children.append(child)
	return group_children


## Counts the number of direct children of the given parent node that are members of the specified group.
## @param parent: The parent Node whose children will be checked.
## @param group: The name of the group to check membership against.
## @return: An integer representing the count of children in the specified group.
static func children_in_group_count(parent: Node, group: StringName) -> int:
	if group == "":
		return 0  # Early exit if group name is empty

	var count: int = 0
	for child in parent.get_children():
		if child.is_in_group(group):
			count += 1
	return count


## Deletes all direct children of the given node that are members of the specified group.
## For each child in that group, its script is removed (set to null) before it is queued for deletion.
static func delete_all_group_children(node: Node, group: String) -> void:
	if not node:
		push_error("[CDUtils] delete_all_group_children: Provided node is null.")
		return
	if group == "":
		push_warning("[CDUtils] delete_all_group_children: Empty group specified; nothing to delete.")
		return
	for child: Node in node.get_children():
		if child.is_in_group(group):
			child.set_script(null)
			child.queue_free()

## Retrieves the next sibling of the given node.
## @param node: The node whose next sibling is to be found.
## @return: The next sibling node, or null if there is none.
static func get_next_sibling(node: Node) -> Variant:
	var parent = node.get_parent()
	if parent:
		var index = parent.get_child_index(node)
		if index < parent.get_child_count() - 1:
			return parent.get_child(index + 1)
	return null

## Recursively finds a node by its name in the scene tree starting from the given root node.
##
## - `node_name`: The name of the node to search for.
## - `root`: The root node to begin the search from.
## - Returns: The first node with the given name if found, `null` if not found.
static func get_node_by_name(node_name: String, root: Node) -> Node:
	# Iterate through all children of the current node
	for child in root.get_children():
		# If the child's name matches the search name, return the child node
		if child.name == node_name:
			return child
		
		# Recursively search in the child's children
		var found: Node = get_node_by_name(node_name, child)
		if found:
			return found
	
	# Return null if the node was not found
	return null


##BUTTON##

## Sets the OptionButton selection based on the provided text.
## If the text is not found, the first item will be selected by default.
##
## - `option_button`: The OptionButton node whose item list is being searched.
## - `text`: The text to search for in the OptionButton items.
static func set_option_by_text(option_button: OptionButton, text: String) -> void:
	# Loop through all items in the OptionButton
	for i in range(option_button.get_item_count()):
		# Get the text of the current item
		var item_text := option_button.get_item_text(i)
		
		# Check if the item text matches the provided text
		if item_text == text:
			option_button.select(i)  # Select the item
			return
	
	# If no matching item is found, select the first item
	option_button.select(0)



####
#DIRECTORY/FILE FUNCTIONS
####


## Checks if a directory exists at the given path.
##
## - `path`: The directory path to check.
## - Returns: `true` if the directory exists, `false` otherwise.
static func dir_exists(path: String) -> bool:
	# Attempt to open the directory
	var dir := DirAccess.open(path)
	# Return false if the directory could not be opened, true otherwise
	return dir != null and dir.is_dir(path)

## Checks if a file exists at the given path.
##
## - `path`: The file path to check.
## - Returns: `true` if the file exists, `false` otherwise.
static func file_exists(path: String) -> bool:
	# Check for the editor environment
	if OS.has_feature("editor"):
		# Attempt to open the file in read mode
		var file: FileAccess = FileAccess.open(path, FileAccess.READ)
		if file:
			file.close()  # Close the file if opened successfully
			return true
		return false
	
	# For non-editor environment, check known resource extensions
	# Add more extensions to the array as needed.
	if path.get_extension() in ["png", "svg", "ttf"]:
		# Check if the resource exists using ResourceLoader
		return ResourceLoader.exists(path)
	
	# For other files, attempt to open the file in read mode
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file:
		file.close()  # Close the file if opened successfully
		return true
	return false




## Attempts to create a directory at the specified path.
## Returns true if the directory was successfully created; otherwise, prints an error message and returns false.
static func create_dir(path: String) -> bool:
	if path.strip_edges() == "":
		push_error("[CDUtils] create_dir: Provided path is empty.")
		return false

	var error_code: int = DirAccess.make_dir_recursive_absolute(path)
	if error_code == OK:
		return true
	else:
		print("[CDUtils] create_dir:", error_string(error_code))
		return false

## Recursively copies the contents of one directory to another.
##
## - `source_path`: The path of the source directory to copy from.
## - `dest_path`: The destination directory to copy to.
## - Returns: `true` if the copy is successful, `false` otherwise.
static func deep_copy_dir(source_path:String, dest_path:String)->bool:
	var source_dir:DirAccess = DirAccess.open(source_path)
	var dest_dir:DirAccess = DirAccess.open(dest_path)
	var source_end:String = source_path.get_file()
	
	if(!dir_exists(source_path)):
		push_error("Source dir does not exist! ", source_path )
		return false
	
	# Open the source directory
	if (source_end.contains(".") ) && DirAccess.get_open_error() != OK:
		push_error("[CDUtils] deep_copy_dir: \nFailed to open source directory: " + source_path, "\nError: ", error_string(DirAccess.get_open_error() ))
		return false
	
	var new_dest_path:String = dest_path+"/"+source_end
	# Ensure the destination directory exists
	if DirAccess.get_open_error() == OK:
		var make_dir_err:Error = dest_dir.make_dir(new_dest_path)
		if make_dir_err != OK && make_dir_err != ERR_ALREADY_EXISTS:
			push_error("[CDUtils] deep_copy_dir: \nFailed to make destination directory: " + dest_path, "\nError: ", error_string(make_dir_err))
			return false
	else:
		push_error("[CDUtils] deep_copy_dir: \nFailed to open destination directory! ", dest_path)
		return false
	
	source_dir.list_dir_begin()  # Begin listing the directory
	while true:
		var item:String = source_dir.get_next()
		if item == "":
			break  # No more items
		
		if item == "." or item == "..":
			continue  # Skip special directories
		
		var source_item_path:String = source_path + "/" + item
		var dest_item_path:String = new_dest_path
		
		if source_dir.current_is_dir():
			# Recursively copy subdirectories
			if not deep_copy_dir(source_item_path, dest_item_path):
				return false
		else:
			# Copy files
			var file:FileAccess = FileAccess.open(source_item_path, FileAccess.READ)
			if FileAccess.get_open_error() != OK:
				push_error("[CDUtils] deep_copy_dir: Failed to open file: " + source_item_path)
				return false
			var data:PackedByteArray = file.get_buffer(file.get_length())
			file.close()
			
			file = FileAccess.open(dest_item_path + "/" + item, FileAccess.WRITE)
			if FileAccess.get_open_error() != OK:
				push_error("[CDUtils] deep_copy_dir: Failed to create file: " + dest_item_path+ "/" + item)
				return false
			file.store_buffer(data)
			file.close()
	
	source_dir.list_dir_end()  # Clean up
	return true


## Recursively deletes a directory and all its contents.
## It iterates over all entries in the directory (skipping '.' and '..'), deleting files and recursively deleting subdirectories.
## Finally, it removes the (now empty) directory itself.
## Returns true if the directory was successfully deleted; otherwise, prints an error and returns false.
static func deep_remove_dir(path: String) -> bool:
	if path.strip_edges() == "":
		push_error("[CDUtils] deep_remove_dir: Provided path is empty.")
		return false

	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		push_error("[CDUtils] deep_remove_dir: Could not open directory at: " + path)
		return false

	var err: int = dir.list_dir_begin()
	if err != OK:
		push_error("[CDUtils] deep_remove_dir: Failed to list directory: " + path)
		return false

	var entry: String = dir.get_next()
	while entry != "":
		# Skip special entries.
		if entry == "." or entry == "..":
			entry = dir.get_next()
			continue

		var entry_path: String = path.path_join(entry)
		if dir.current_is_dir():
			print("[CDUtils] deep_remove_dir: Found directory: " + entry_path)
			if not deep_remove_dir(entry_path):
				dir.list_dir_end()
				return false
		else:
			print("[CDUtils] deep_remove_dir: Found file: " + entry_path)
			if dir.remove(entry_path) != OK:
				push_error("[CDUtils] deep_remove_dir: Failed to delete file: " + entry_path)
				dir.list_dir_end()
				return false
		entry = dir.get_next()

	dir.list_dir_end()

	# Now that the directory is empty, remove it.
	var removal_error: int = dir.remove(path)
	if removal_error != OK:
		push_error("[CDUtils] deep_remove_dir: Failed to remove directory: " + path)
		return false

	print("[CDUtils] deep_remove_dir: Successfully deleted directory: " + path)
	return true

## Lists all subdirectories in the specified path.
## @param path: The path to the directory to list subdirectories from.
## @return: A PackedStringArray containing the names of all subdirectories.
static func list_folders_in_dir(path: String) -> PackedStringArray:
	var dir:DirAccess = DirAccess.open(path)
	var folders = PackedStringArray()

	if dir.get_open_error() == OK:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if dir.current_is_dir() and not file.begins_with("."):
				folders.append(file)
			file = dir.get_next()
		dir.list_dir_end()
	else:
		push_error("[CDUtils] list_folders_in_dir: Failed to open directory: " + path)

	return folders

## Saves the given content to a file at the specified filepath.
## @param filepath: The path to the file where the content will be saved.
## @param content: The text content to be written to the file.
## @return: Returns `true` if the file was successfully saved; otherwise, `false`.
static func save_text_file(filepath: String, content: String) -> bool:
	var file: FileAccess = FileAccess.open(filepath, FileAccess.ModeFlags.WRITE)
	if file:
		file.store_string(content)
		file.close()
		return true
	else:
		return false

## Deletes a file at the given path. Returns true if successful, false otherwise.
static func delete_file(file_path: String) -> bool:
	if not FileAccess.file_exists(file_path):
		print("[CDUtils] delete_file: File does not exist - ", file_path)
		return false

	var dir := DirAccess.open("user://")
	if dir == null:
		printerr("[CDUtils] delete_file: Failed to access directory.")
		return false

	if dir.remove(file_path) == OK:
		print("[CDUtils] delete_file: File deleted - ", file_path)
		return true
	else:
		printerr("[CDUtils] delete_file: Failed to delete file - ", file_path)
		return false



## Loads the content of a file as a string.
## @param path: The path to the file to be read.
## @return: The content of the file as a string, or an error message if the file could not be read.
static func load_file_as_string(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.ModeFlags.READ)
	if file:
		var content: String = file.get_as_text()
		file.close()
		return content
	else:
		push_error("[CDUtils] load_file_as_string: Unable to open file at path - " + path + " - error - " + error_string(file.get_open_error()) )
		return ""

## Copies a file from the source path to the destination path.
## @param source_path: The path to the source file.
## @param destination_path: The path to the destination file.
## @return: Returns `true` if the file was successfully copied; otherwise, `false`.
static func copy_file(source_path: String, destination_path: String) -> bool:
	var dir: DirAccess = DirAccess.open("user://")
	if dir:
		var err: int = dir.copy(source_path, destination_path)
		if err == OK:
			return true
		else:
			push_error("[CDUtils] copy_file: Failed to copy file from '%s' to '%s'. Error code: %d" % [source_path, destination_path, err])
			return false
	else:
		push_error("[CDUtils] copy_file: Failed to access the directory.")
		return false


#STRING FUNCTIONS

## Removes all numeric characters from the input string.
## @param input_string: The string from which numbers will be removed.
## @return: A new string with all numeric characters removed.
static func remove_nums(input_string: String) -> String:
	var pattern: String = r"\d+"
	var regex: RegEx = RegEx.new()
	var error = regex.compile(pattern)
	if error != OK:
		push_error("[CDUtils] remove_nums: Failed to compile regex pattern.")
		return input_string  # Return the original string if regex compilation fails
	return regex.sub(input_string, "", true)


## Removes all alphabetic characters from the input string.
## @param input_string: The string from which letters will be removed.
## @return: A new string with all alphabetic characters removed.
static func remove_letters(input_string: String) -> String:
	var pattern: String = r"[a-zA-Z]+"
	var regex: RegEx = RegEx.new()
	var error = regex.compile(pattern)
	if error != OK:
		push_error("[CDUtils] remove_letters: Failed to compile regex pattern.")
		return input_string  # Return the original string if regex compilation fails
	return regex.sub(input_string, "", true)


## Removes all non-alphanumeric and non-whitespace characters from the input string.
## @param input_string: The string from which symbols will be removed.
## @return: A new string with all symbols removed.
static func remove_symbols(input_string: String) -> String:
	var pattern: String = r"[^\w\s]+"  # Matches anything that isn't a letter, number, or space
	var regex: RegEx = RegEx.new()
	var error = regex.compile(pattern)
	
	if error != OK:
		push_error("[CDUtils] remove_symbols: Failed to compile regex pattern.")
		return input_string  # Return original string if regex fails
	
	return regex.sub(input_string, "", true)

## Generates a unique filename by appending a numerical suffix if necessary.
## @param path: The desired file path.
## @return: A unique file path as a String.
static func make_file_unique(path: String) -> String:
	# Validate the input path
	if path == "":
		push_error("[CDUtils] make_file_unique: The provided path is an empty string.")
		return ""

	var dir: DirAccess = DirAccess.open(path.get_base_dir())
	if dir == null:
		push_error("[CDUtils] make_file_unique: The directory '%s' does not exist." % [path.get_base_dir()])
		return ""

	var count: int = 0
	var filename_parts: Array[String] = path.get_file().rsplit(".", false, 1)
	var unique_suffix: String = ""

	# Ensure the filename has both name and extension
	if filename_parts.size() < 2:
		push_error("[CDUtils] make_file_unique: The filename '%s' does not have an extension." % [path.get_file()])
		return ""

	var base_name: String = filename_parts[0]
	var extension: String = filename_parts[1]

	# Check for existing files and generate a unique filename
	while FileAccess.file_exists(path.get_base_dir().path_join(base_name + unique_suffix + "." + extension)):
		count += 1
		unique_suffix = "(%d)" % count

	return path.get_base_dir().path_join(base_name + unique_suffix + "." + extension)


## Generates a unique directory name by appending a numerical suffix if necessary.
## @param path: The desired directory path.
## @return: A unique directory path as a String.
static func make_dir_unique(path: String) -> String:
	# Validate the input path
	if path == "":
		push_error("[CDUtils] make_dir_unique: The provided path is an empty string.")
		return ""

	var dir: DirAccess = DirAccess.open(path.get_base_dir())
	if dir == null:
		push_error("[CDUtils] make_dir_unique: The base directory '%s' does not exist." % [path.get_base_dir()])
		return ""

	var count: int = 0
	var base_name: String = path.get_file()
	var unique_suffix: String = ""

	# Check for existing directories and generate a unique directory name
	while DirAccess.dir_exists_absolute(path.get_base_dir().path_join(base_name + unique_suffix)):
		count += 1
		unique_suffix = "(%d)" % count

	return path.get_base_dir().path_join(base_name + unique_suffix)


## Removes everything after a specific phrase in a string.
## If include_phrase is true, the phrase will be kept in the result.
## Returns the original string if the phrase is not found.
static func remove_after_phrase(my_string: String, phrase: String, include_phrase: bool = false) -> String:
	var position:int = my_string.find(phrase)
	if position == -1:
		return my_string
	
	return my_string.left(position + (phrase.length() if include_phrase else 0))


## Removes everything before a specific phrase in a string.
## If include_phrase is true, the phrase will be kept in the result.
## Returns the original string if the phrase is not found.
static func remove_before_phrase(my_string: String, phrase: String, include_phrase: bool = false) -> String:
	var position:int = my_string.find(phrase)
	if position == -1:
		return my_string
	
	return my_string.right(position + (0 if include_phrase else phrase.length()))


## Returns the appropriate suffix for an ordinal number (1st, 2nd, 3rd, etc.).
##
## - `num`: The number to convert to an ordinal string.
## - Returns: The number as a string with the correct suffix.
static func number_suffix(num: int) -> String:
	# Handle special cases for 11, 12, 13 as they use "th" despite their last digit
	if num % 100 in [11, 12, 13]:
		return str(num) + "th"
	
	# Get the last digit of the number
	var last_digit := num % 10
	
	# Check the last digit and return the appropriate suffix
	if last_digit == 1:
		return str(num) + "st"
	elif last_digit == 2:
		return str(num) + "nd"
	elif last_digit == 3:
		return str(num) + "rd"
	else:
		return str(num) + "th"

## Extracts the drive and the last N folders or file names from the given path.
## If there aren't enough parts in the path, returns the original path.
##
## - `full_path`: The full file or folder path to extract information from.
## - `num_folders`: The number of folders (and/or file) to display in the final path (optional, default is 2).
## - Returns: A string with the drive and the last N folder/file names, or the original path if it's too short.
static func get_drive_and_last_folders(full_path: String, num_folders: int = 2) -> String:
	# Normalize the path by replacing backslashes with forward slashes
	var path_parts: PackedStringArray = full_path.replace("\\", "/").split("/")
	
	# Ensure there are enough parts (drive + at least num_folders folders/files)
	if path_parts.size() < num_folders + 1:
		return full_path  # Not enough parts to extract the desired number of folders or file
	
	# Get the drive part
	var drive: String = path_parts[0]
	
	# Get the last N parts (folder/file)
	var last_parts: String = ""
	for i in range(num_folders):
		last_parts += "/" + path_parts[path_parts.size() - num_folders + i]
	
	# Check if the last part is a file or folder
	var last_part := path_parts[path_parts.size() - 1]
	if last_part.find(".") != -1:  # Assuming it's a file if it contains a period
		# It's a file, return drive + last N folder/file parts
		return drive + "/.../" + last_parts
	else:
		# It's a folder, return drive + last N folders
		return drive + "/.../" + last_parts

## Helper function to check if a string contains only valid hexadecimal characters (0-9, a-f, A-F).
##
## - `st`: The string to check.
## - Returns: `true` if the string contains only valid hexadecimal characters, `false` otherwise.
static func is_valid_hex(st: String) -> bool:
	# Check if all characters in the string are valid hexadecimal digits
	for c in st:
		if not c in ("0123456789abcdefABCDEF"):
			return false
	return true


## Formats a UUID string into the standard format (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx).
##
## - `uuid_string`: The raw UUID string to format (should be 32 characters long without hyphens).
## - Returns: A formatted UUID string, or an empty string if the input is invalid.
static func format_uuid(uuid_string: String) -> String:
	# Check if the input string has the correct length for a UUID (32 characters)
	if uuid_string.length() != 32:
		print("Invalid UUID string length: ", uuid_string.length(), ". Expected 32 characters.")
		return ""
	
	# Check if the input string contains only valid hexadecimal characters
	if !is_valid_hex(uuid_string):
		print("Invalid UUID string, contains non-hexadecimal characters: ", uuid_string)
		return ""

	# Insert hyphens at the appropriate positions to match the UUID format
	var formatted_uuid: String = uuid_string.substr(0, 8) + "-" + uuid_string.substr(8, 4) + "-" + uuid_string.substr(12, 4) + "-" + uuid_string.substr(16, 4) + "-" + uuid_string.substr(20, 12)

	return formatted_uuid




####
#MATH FUNCTIONS
####

static func approx_equal(v1: float, v2: float, epsilon: float = 0.001) -> bool:
	return abs(v1 - v2) < epsilon

static func round_places(num:float ,places:int) -> float:
	return (round(num*pow(10,places))/pow(10,places))

## Scales a number from an original range to a new range.
## @param number: The float value to be scaled.
## @param old_range: A Vector2 representing the original range, where x is the minimum and y is the maximum.
## @param new_range: A Vector2 representing the target range, where x is the minimum and y is the maximum.
## @return: The scaled float value.
static func scale_num_to_range(number: float, old_range: Vector2, new_range: Vector2) -> float:
	# Validate the original range to prevent division by zero
	if old_range.x == old_range.y:
		push_error("[CDUtils] scale_num_to_range: The original range is zero (old_range.x == old_range.y).")
		return new_range.x  # Return the minimum of the new range as a fallback

	# Calculate the spans of the old and new ranges
	var old_span: float = old_range.y - old_range.x
	var new_span: float = new_range.y - new_range.x

	# Scale the number to the new range
	var scaled_value: float = ((number - old_range.x) / old_span) * new_span + new_range.x

	return scaled_value


####
#COLOUR FUNCTIONS
####

## Determines whether black or white text provides better contrast against a given background color.
## @param background: The background Color.
## @return: Color.BLACK if black text is more legible; otherwise, Color.WHITE.
static func contrast_text(background: Color, threshold:float = 0.73) -> Color:
	# Calculate luminance (perceived brightness) of the background color
	var luminance: float = background.r * 0.299 + background.g * 0.587 + background.b * 0.114
	
	# Choose black or white text based on the luminance
	if luminance > threshold:
		return Color.BLACK  # Use black text for light backgrounds
	else:
		return Color.WHITE  # Use white text for dark backgrounds



####
#AUDIO FUNCTIONS
####


## Converts a pitch difference in cents to a frequency scale factor.
## @param pitch_cents: The pitch difference in cents as a float.
## @return: The corresponding frequency scale factor as a float.
static func cents_to_scale(pitch_cents: float) -> float:
	# Define the constant for cents to semitone conversion
	const CENTS_PER_OCTAVE: float = 1200.0

	# Check for edge cases: if pitch_cents is not a finite number
	if not is_finite(pitch_cents):
		push_error("[CDUtils] cents_to_scale: pitch_cents must be a finite number.")
		return 1.0  # Return a neutral scale factor

	# Calculate the pitch ratio
	var pitch_ratio: float = pow(2.0, pitch_cents / CENTS_PER_OCTAVE)

	return pitch_ratio


## Loads an MP3 file from the given path and returns an AudioStreamMP3 instance.
## Returns null if the file cannot be loaded.
static func load_mp3(file_path: String) -> AudioStreamMP3:
	if not FileAccess.file_exists(file_path):
		push_error("[CDUtils] load_mp3: File does not exist - " + file_path)
		return null

	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("[CDUtils] load_mp3: Failed to open file - " + file_path)
		return null

	var sound := AudioStreamMP3.new()
	var file_size := file.get_length()
	
	if file_size <= 0:
		push_error("[CDUtils] load_mp3: File is empty or unreadable - " + file_path)
		return null

	sound.data = file.get_buffer(file_size)
	return sound
