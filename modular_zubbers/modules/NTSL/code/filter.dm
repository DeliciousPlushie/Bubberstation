/**
 * Yogstation's preety filter, in a smaller package restricted only to NTSL
 * It has no effect on anything thats not NTSL code
 */

/proc/setup_pretty_filter(path = "config/ntsl_filter.txt")
	var/list/filter_lines = world.file2list(path)
	for(var/line in filter_lines)
		add_pretty_filter_line(line)

// Add a filter pair
/proc/add_pretty_filter_line(line)
	if(findtextEx(line,"#",1,2) || length(line) == 0)
		return

	//Split the line at every "="
	var/list/parts = splittext(line, "=")
	if(!length(parts))
		return FALSE

	//pattern is before the first "="
	var/pattern = parts[1]
	if(!pattern)
		return FALSE

	//replacement follows the first "="
	var/replacement = ""
	if(length(parts) >= 2)
		var/index = 2
		for(index = 2; index <= length(parts); index++)
			replacement += parts[index]
			if(index < length(parts))
				replacement += "="

	if(!replacement)
		return FALSE

	GLOB.pretty_filter_items.Add(line)
	return TRUE

/proc/isnotpretty(text) // A simpler version of pretty_filter(), where all it returns is whether it had to replace something or not.
	//Useful for the "You fumble your words..." business.
	for(var/line in GLOB.pretty_filter_items)
		var/list/parts = splittext(line, "=")
		var/pattern = parts[1]
		var/regex/current_regex = new(pattern, "ig")
		if(current_regex.Find(text)) //If found
			return TRUE // Yes, it isn't pretty.
	return FALSE // No, it is pretty.

//Returns null if there is any bad text in the string
/proc/reject_bad_ntsl_text(text, ascii_only = TRUE, require_pretty = TRUE, allow_newline = FALSE, allow_code = FALSE)
	if(require_pretty && isnotpretty(text))
		return
	var/non_whitespace = FALSE
	var/lenbytes = length(text)
	var/char = ""
	for(var/i = 1, i <= lenbytes, i += length(char))
		char = text[i]
		switch(text2ascii(char))
			if(9) // 自定义修改：把制表符单独作为空白处理
				if(!allow_code)
					return
			if(62, 60, 92, 47) // 自定义修改：允许的代码符号计入非空白字符
				if(!allow_code)
					return
				non_whitespace = TRUE
			if(10, 13) //Carriage returns (CR) and newline (NL)
				if(!allow_newline)
					return
			if(0 to 8)
				return
			if(11, 12)
				return
			if(14 to 31)
				return
			if(32)
				continue
			if(127 to 159) // 自定义修改：即使源码允许中文，也须拒绝 DEL 和 C1 控制字符
				return
			if(160 to INFINITY) // 自定义修改：允许 Unicode 源码进入词法检查，以便报告所在行
				if(ascii_only)
					return
				non_whitespace = TRUE
			else
				non_whitespace = TRUE
	if(non_whitespace)
		return text		//only accepts the text if it has some non-spaces
