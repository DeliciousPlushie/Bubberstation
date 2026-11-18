/datum/scriptError
	///A message describing the problem.
	var/message

/datum/scriptError/New(msg)
	if(msg)
		message = msg

/datum/scriptError/BadToken
	message = "意外的词元："
	var/datum/token/token

/datum/scriptError/BadToken/New(datum/token/token)
	src.token = token

	if(token && token.line)
		message = "[token.line]: [message]"
	if(istype(token))
		message += "[token.value]"
	else
		message += "[token]"

/datum/scriptError/InvalidID
	parent_type = /datum/scriptError/BadToken
	message = "无效的标识符："

/datum/scriptError/ReservedWord
	parent_type = /datum/scriptError/BadToken
	message = "标识符使用了保留字："

/datum/scriptError/BadNumber
	parent_type = /datum/scriptError/BadToken
	message = "无效的数字："

/datum/scriptError/BadReturn
	message = "函数外出现了 return 语句。"
	var/datum/token/token

/datum/scriptError/BadReturn/New(datum/token/token)
	src.token = token

/datum/scriptError/EndOfFile
	message = "文件意外结束。"

/datum/scriptError/ExpectedToken
	message = "此处应为"

/datum/scriptError/ExpectedToken/New(id, datum/token/token)
	if(token)
		message = "[token.line ? token.line : "???"]：[message]“[id]”，实际读到“[token.value]”。"
	else
		message = "???：[message]“[id]”，但没有读到词元。"

/datum/scriptError/UnterminatedComment
	message = "多行注释未结束，缺少 */。"

/datum/scriptError/DuplicateFunction

/datum/scriptError/DuplicateFunction/New(name, datum/token/token)
	message = "函数“[name]”重复定义。"

/datum/scriptError/ParameterFunction
	message = "不能在参数中使用函数。"

/datum/scriptError/ParameterFunction/New(datum/token/token)
	var/line = "???"
	if(token)
		line = token.line
	message = "[line]: [message]"

/datum/scriptError/InvalidAssignment
	message = "无法给赋值语句左侧的表达式赋值。"

/datum/scriptError/OutdatedScript
	message = "这段脚本似乎是为旧版 NTSL 编写的，运行结果可能不符合预期。请查阅文档中的新语法和 API。"

/*
 * Runtime Error
 * An error thrown by the interpreter in running the script.
 */
/datum/runtimeError
	var/name
	///A basic description as to what went wrong.
	var/message
	var/datum/scope/scope
	var/datum/token/token

///Returns a description of the error suitable for showing to the user.
/datum/runtimeError/proc/ToString()
	. = "[name]: [message]"
	if(!scope)
		return
	var/last_line
	var/last_col
	if(token)
		last_line = token.line
		last_col = token.column
	var/datum/scope/cur_scope = scope
	while(cur_scope)
		if(cur_scope.function)
			. += "\n\t位于 [cur_scope.function.func_name]（[last_line]:[last_col]）"
			if(cur_scope.call_node && cur_scope.call_node.token)
				last_line = cur_scope.call_node.token.line
				last_col = cur_scope.call_node.token.column
			else
				last_line = null
				last_col = null
		cur_scope = cur_scope.parent
	if(last_line)
		. += "\n\t位于全局作用域（[last_line]:[last_col]）"
	else
		. += "\n\t位于解释器内部"

/datum/runtimeError/TypeMismatch
	name = "类型不匹配"

/datum/runtimeError/TypeMismatch/New(op, a, b)
	if(isnull(a))
		a = "NULL"
	if(isnull(b))
		b = "NULL"
	message = "运算两侧的类型不匹配：“[a]” [op] “[b]”"

/datum/runtimeError/UnexpectedReturn
	name = "返回语句错误"
	message = "此处不应出现 return 语句。"

/datum/runtimeError/UnknownInstruction
	name = "未知指令"

/datum/runtimeError/UnknownInstruction/New(datum/ntsl_node/op)
	message = "未知的指令类型“[op.type]”。编译器和解释器的版本可能不兼容，也可能尚未实现该指令。"

/datum/runtimeError/UndefinedVariable
	name = "未定义的变量"

/datum/runtimeError/UndefinedVariable/New(variable)
	message = "变量“[variable]”尚未声明。"

/datum/runtimeError/IndexOutOfRange
	name = "索引越界"

/datum/runtimeError/IndexOutOfRange/New(obj, idx)
	message = "索引 [obj]\[[idx]] 超出范围。"

/datum/runtimeError/UndefinedFunction
	name = "未定义的函数"

/datum/runtimeError/UndefinedFunction/New(function)
	message = "函数“[function]()”尚未定义。"

/datum/runtimeError/DuplicateVariableDeclaration
	name = "变量重复声明"

/datum/runtimeError/DuplicateVariableDeclaration/New(variable)
	message = "变量“[variable]”已经声明过了。"

/datum/runtimeError/IterationLimitReached
	name = "循环次数超限"
	message = "循环次数已达上限。"

/datum/runtimeError/RecursionLimitReached
	name = "递归深度超限"
	message = "递归深度已达上限。"

/datum/runtimeError/DivisionByZero
	name = "除数错误"
	message = "尝试用零或 NULL 值作除数。"

/datum/runtimeError/InvalidAssignment
	message = "无法给赋值语句左侧的表达式赋值。"

/datum/runtimeError/MaxCPU
	name = "计算量超限"

/datum/runtimeError/MaxCPU/New(maxcycles)
	message = "计算周期数已达上限（>= [maxcycles]）。"

/datum/runtimeError/Internal
	name = "内部错误"

/datum/runtimeError/Internal/New(exception/exception_message)
	message = exception_message.name
