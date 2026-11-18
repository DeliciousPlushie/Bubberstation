/**
 * Unary Operators
 *
 * Unary
 * Represents a Unary operator in the AST.
 * Unary operators take a single operand (referred to as 'x' below) and returns a value.
 */
/datum/ntsl_node/expression/expression_operator/unary
	precedence = OOP_UNARY

/**
 * LogicalNot
 * Returns !x
 *
 * Ex: !TRUE = FALSE and !FALSE = TRUE
 */
/datum/ntsl_node/expression/expression_operator/unary/LogicalNot
	name = "逻辑非"

/**
 * BitwiseNot
 * Returns the value of a bitwise not operation performed on x
 *
 * Ex: ~10 (decimal 2) = 01 (decimal 1)
 */
/datum/ntsl_node/expression/expression_operator/unary/BitwiseNot
	name = "按位取反"

/**
 * Minus
 * Returns -x
 */
/datum/ntsl_node/expression/expression_operator/unary/Minus
	name = "取负"

/**
 * Group
 * A special unary operator representing a value in parentheses.
 */
/datum/ntsl_node/expression/expression_operator/unary/group
	precedence = OOP_GROUP
