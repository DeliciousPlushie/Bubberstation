#define COLUMN_LOCATION (codepos-linepos)

/*
 * n_Scanner
 * An object responsible for breaking up source code into tokens for use by the parser.
 */
/datum/n_Scanner
	var/code
	///A list of fatal errors found by the scanner. If there are any items in this list, then it is not safe to parse the returned tokens.
	var/list/errors = new
	///A list of non-fatal problems in the source code found by the scanner.
	var/list/warnings = new

///Loads source code.
/datum/n_Scanner/proc/LoadCode(c)
	code = c

///Gets the code from a file and calls LoadCode()
/datum/n_Scanner/proc/LoadCodeFromFile(f)
	LoadCode(file2text(f))

///Runs the scanner and returns the resulting list of tokens. Ensure that <LoadCode()> has been called first.
/datum/n_Scanner/proc/Scan()

/*
 * nS_Scanner
 * A scanner implementation for n_Script.
 */
/datum/n_Scanner/nS_Scanner

	///The scanner's position in the source code.
	var/codepos = 1
	var/line = 1
	var/linepos = 0
	var/datum/n_scriptOptions/options

	///List of characters that end a statement. Each item may only be one character long. Default is a semicolon.
	var/list/end_stmt = list(";")
	///List of characters that are ignored by the scanner. Default is whitespace.
	var/list/ignore = list(" ", "\t", "\n")
	///List of characters that can start and end strings. Default is double and single quotes.
	var/list/string_delim = list("\"", "'")
	///List of characters that denote the start of a new token. This list is automatically populated.
	var/list/delim = new


/datum/n_Scanner/nS_Scanner/New(code, datum/n_scriptOptions/options)
	. = ..()
	src.options = options
	src.ignore += ascii2text(13) //Carriage return
	src.delim += ignore + options.symbols + end_stmt + string_delim
	LoadCode(code)

/datum/n_Scanner/nS_Scanner/Destroy(force)
	options = null
	return ..()

/datum/n_Scanner/nS_Scanner/Scan()
	var/list/datum/token/tokens = new
	for(, codepos <= length(code), codepos++)
		var/char = code[codepos] // 自定义修改：按字节位置读取完整字符，以识别语法位置的非 ASCII 输入
		if(length(char) > 1)
			errors += new /datum/scriptError("第 [line] 行：“[char]”只能出现在字符串或注释中；语法符号请使用半角字符。")
			break
		if(char == "\n")
			line++
			linepos = codepos

		if(ignore.Find(char))
			continue
		else if(char == "/" && codepos < length(code) && (code[codepos + 1] in list("/", "*"))) // 自定义修改：只在斜杠后按完整字符识别注释
			ReadComment()
		else if(end_stmt.Find(char))
			tokens += new /datum/token/end(char, line, COLUMN_LOCATION)
		else if(string_delim.Find(char))
			codepos++ //skip string delimiter
			tokens += ReadString(char)
		else if(options.CanStartID(char))
			tokens += ReadWord()
		else if(options.IsDigit(char))
			tokens += ReadNumber()
		else if(options.symbols.Find(char))
			tokens += ReadSymbol()

	codepos = initial(codepos)
	line = initial(line)
	linepos = initial(linepos)
	return tokens

/**
 * ReadString
 * Reads a string in the source code into a token.
 * Arguments:
 * start - The character used to start the string.
 */
/datum/n_Scanner/nS_Scanner/proc/ReadString(start)
	var/buf
	var/char // 自定义修改：用当前字符的 UTF-8 字节宽度推进字符串游标
	for(, codepos <= length(code), codepos += length(char))
		char = code[codepos]
		switch(char)
			if("\\")					//Backslash (\) encountered in string
				codepos++ //Skip next character in string, since it was escaped by a backslash
				if(codepos > length(code)) // 自定义修改：末尾孤立的反斜杠没有可读取的转义字符
					break
				char = code[codepos] // 自定义修改：转义分支也保留完整的多字节字符
				switch(char)
					if("\\") //Double backslash
						buf += "\\"
					if("n")				//\n Newline
						buf += "\n"
					else
						if(char == start) //\" Doublequote
							buf += start
						else				//Unknown escaped text
							buf += char
			if("\n")
				. = new /datum/token/string(buf, line, COLUMN_LOCATION)
				errors += new /datum/scriptError("字符串尚未闭合就遇到了换行符。", .)
				line++
				linepos = codepos
				break
			else
				if(char == start) //string delimiter found, end string
					break
				else
					buf += char //Just a normal character in a string
	if(codepos > length(code)) // 自定义修改：文件结束仍未闭合时报告字符串所在行
		errors += new /datum/scriptError("第 [line] 行：字符串缺少结束引号。")
	if(!.)
		return new /datum/token/string(buf, line, COLUMN_LOCATION)

///Reads characters separated by an item in <delim> into a token.
/datum/n_Scanner/nS_Scanner/proc/ReadWord()
	var/buf
	for(, codepos <= length(code), codepos++) // 自定义修改：单词遇到中文时交还主扫描器，以便报告非法标识符
		var/char = code[codepos]
		if(length(char) > 1 || delim.Find(char))
			break
		buf += char
	codepos-- //allow main Scan() proc to read the delimiter
	if(options.keywords.Find(buf))
		return new /datum/token/keyword(buf, line, COLUMN_LOCATION)
	else
		return new /datum/token/word(buf, line, COLUMN_LOCATION)

///Reads a symbol into a token.
/datum/n_Scanner/nS_Scanner/proc/ReadSymbol()
	var/char = copytext(code, codepos, codepos + 1)
	var/buf

	while(options.symbols.Find(buf+char))
		buf += char
		if(++codepos > length(code))
			break
		char = code[codepos] // 自定义修改：前瞻完整字符，使紧邻运算符的中文能回到主扫描器报错

	codepos-- //allow main Scan() proc to read the next character
	return new /datum/token/symbol(buf, line, COLUMN_LOCATION)

///Reads a number into a token.
/datum/n_Scanner/nS_Scanner/proc/ReadNumber()
	var/char = copytext(code, codepos, codepos + 1)
	var/buf
	var/dec = 0

	while(options.IsDigit(char) || (char == "." && !dec))
		if(char == ".")
			dec = 1
		buf += char
		codepos++
		char = codepos <= length(code) ? code[codepos] : "" // 自定义修改：数字结束时前瞻完整字符并处理文件结尾
	var/datum/token/number/T = new(buf, line, COLUMN_LOCATION)
	if(isnull(text2num(buf)))
		errors += new /datum/scriptError("无效的数字：", T)
		T.value = 0
	codepos-- //allow main Scan() proc to read the next character
	return T

/*
 * ReadComment
 * Reads a comment. Wow.
 * I'm glad I wrote this proc description for you to explain that.
 * Unlike the other Read functions, this one doesn't have to return any tokens,
 * since it's just "reading" comments.
 * All it does is just pass var/codepos through the comments until it reaches the end of'em.
 */
/datum/n_Scanner/nS_Scanner/proc/ReadComment()
	var/block_comment = code[codepos + 1] == "*" // 自定义修改：两种注释共用 UTF-8 字符游标，保留换行位置与结束标记
	var/char
	for(codepos += 2, codepos <= length(code), codepos += length(char))
		char = code[codepos]
		if(char == "\n")
			line++
			linepos = codepos
			if(!block_comment)
				return
		else if(block_comment && char == "*" && codepos < length(code) && code[codepos + 1] == "/")
			codepos++
			return
	if(block_comment)
		errors += new /datum/scriptError/UnterminatedComment()

#undef COLUMN_LOCATION
