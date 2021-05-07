BUILTINS = []

function builtin (name_list)
    function add(fn)
        for name in name_list
            BUILTINS.append((name, fn, names[0]))
        end
        return fn
    end
    return add
end



function scheme_stringp(x)
    return (typeof(x) == String) and x.startswith('"')
end

scheme_stringp = builtin("string?")(scheme_stringp)

function scheme_symbolp(x):
    return (typeof(x) == String) and ~scheme_stringp(x)
end

scheme_symbolp = builtin("boolean?")(scheme_symbolp)

function validate_type(val, predicate, k, name):
    """Returns VAL.  Raises a SchemeError if not PREDICATE(VAL)
    using "argument K of NAME" to describe the offending value."""
    if ~predicate(val):
        type = type(val)
        if scheme_symbolp(val):
            type = Symbol
        end
        raise SchemeError("argument $k of $name has wrong type $type_name")
    return val
        
function scheme_booleanp(x)
    return x == True || x == False
end

scheme_booleanp = builtin("boolean?")(scheme_booleanp)

function is_true_primitive(val)
    return val != False
end

function is_false_primitive(val)
    return val == False
end

function scheme_not(x)
    return ~is_true_primitive(x)
end

scheme_not = builtin("not")(scheme_not)

function scheme_pairp(x)
    return typeof(x) == Pair #TODO see if this can be overloaded
end
scheme_pairp = builtin("pair?")(scheme_pairp)

function scheme_nullp(x)
    return type(x) == Void
end
scheme_nullp = builtin("null?")(scheme_nullp)

function scheme_promisep(x)
    return type(x) == Promise
end
scheme_promisep = builtin("promise?")(scheme_promisep)

function scheme_valid_cdrp(x)
    return scheme_pairp(x) || scheme_nullp(x) || scheme_promisep(x)
end
scheme_valid_cdrp = builtin("pair?")(scheme_valid_cdrp)

function scheme_equalp(x, y)
    if scheme_pairp(x) && scheme_pairp(y):
        return scheme_equalp(x.first, y.first) && scheme_equalp(x.rest, y.rest)
    elseif scheme_numberp(x) && scheme_numberp(y)
        return x == y
    else
        return type(x) == type(y) && x == y
    end
end

scheme_equalp = builtin("equal?")(scheme_equalp)

function scheme_eqvp(x)
    if scheme_pairp(x) && scheme_pairp(y)
        return x == y
    elseif scheme_symbolp(x) && scheme_symbolp(y)
        return x == y
    else
        return x === y
    end
end
scheme_eqvp = builtin("eqv?")(scheme_eqvp)

 
"eq?")
function scheme_eqp(x, y)
    if scheme_symbolp(x) && scheme_symbolp(y)
        return x == y
    else
        return x === y
    end
end
scheme_eqp = builtin("eq?")(scheme_eqp)
 
# Streams
    
function scheme_force(x)
    validate_type(x, scheme_promisep, 0, 'promise')
    return x.evaluate() #TODO what is evaluate; it's not eval
end
scheme_force = builtin("force?")(scheme_force)
 
function scheme_cdr_stream(x)
    lambda_x = scheme_pairp(x) and scheme_promisep(x.rest)
    validate_type(x, lambda_x, 0, 'cdr-stream')
    return scheme_force(x.rest)
end
scheme_cdr_stream = builtin("cdr_stream?")(scheme_cdr_stream)
 

function scheme_listp(x)
    """Return whether x is a well-formed list. Assumes no cycles."""
    while x is not Void
        if not isinstance(x, Pair)
            return False
        end
        x = x.rest
    end
    return True
end
scheme_listp = builtin("list?")(scheme_listp)
 

function scheme_length(x)
    validate_type(x, scheme_listp, 0, 'length')
    if x is Void
        return 0
    end
    return len(x)
end
scheme_length = builtin("length?")(scheme_length)
 

function scheme_cons(x, y)
    return Pair(x, y)
end
scheme_cons = builtin("cons?")(scheme_cons)
 

function scheme_car(x)
    validate_type(x, scheme_pairp, 0, 'car')
    return x.first
end
scheme_car = builtin("car?")(scheme_car)
 

function scheme_cdr(x)
    validate_type(x, scheme_pairp, 0, 'cdr')
    return x.rest
end
scheme_cdr = builtin("cdr?")(scheme_cdr)
 
function scheme_set_car(x, y)
    validate_type(x, scheme_pairp, 0, 'set-car!')
    x.first = y
end
scheme_set_car = builtin("set_car?")(scheme_set_car)
 

function scheme_set_cdr(x, y)
    validate_type(x, scheme_pairp, 0, 'set-cdr!')
    validate_type(y, scheme_valid_cdrp, 1, 'set-cdr!')
    x.rest = y
end
scheme_set-cdr = builtin("set-cdr?")(scheme_set-cdr)
 
"list")
function scheme_list(*vals)
    result = nil
    for e in reversed(vals)
        result = Pair(e, result)
    return result
end
scheme_p = builtin("?")(scheme_p)
 
"append")
function scheme_append(*vals)
    if len(vals) == 0:
        return nil
    result = vals[-1]
    for i in range(len(vals)-2, -1, -1)
        v = vals[i]
        if v is not nil:
            validate_type(v, scheme_pairp, i, 'append')
            r = p = Pair(v.first, result)
            v = v.rest
            while scheme_pairp(v)
                p.rest = Pair(v.first, result)
                p = p.rest
                v = v.rest
            result = r
    return result
end
scheme_p = builtin("?")(scheme_p)
 
"string?")
 
"number?")
function scheme_numberp(x)
    return isinstance(x, numbers.Real) and not scheme_booleanp(x)
scheme_p = builtin("?")(scheme_p)
end
 
"integer?")
function scheme_integerp(x)
    return scheme_numberp(x) and (isinstance(x, numbers.Integral) or int(x) == x)
scheme_p = builtin("?")(scheme_p)
end
 
function _check_nums(*vals)
    """Check that all arguments in VALS are numbers."""
    for i, v in enumerate(vals)
        if not scheme_numberp(v)
            msg = "operand {0} ({1}) is not a number"
            raise SchemeError(msg.format(i, v))
end
 
function _arith(fn, init, vals)
    """Perform the FN operation on the number values of VALS, with INIT as
    the value when VALS is empty. Returns the result as a Scheme value."""
    _check_nums(*vals)
    s = init
    for val in vals:
        s = fn(s, val)
    s = _ensure_int(s)
    return s
end
 
function _ensure_int(x)
    if int(x) == x:
        x = int(x)
    return x
end
 
"+")
function scheme_add(*vals)
    return _arith(operator.add, 0, vals)
end
scheme_p = builtin("?")(scheme_p)
 
"-")
function scheme_sub(val0, *vals)
    _check_nums(val0, *vals) # fixes off-by-one error
    if len(vals) == 0:
        return _ensure_int(-val0)
    return _arith(operator.sub, val0, vals)
end
scheme_p = builtin("?")(scheme_p)
 
"*")
function scheme_mul(*vals)
    return _arith(operator.mul, 1, vals)
end
scheme_p = builtin("?")(scheme_p)
 
"/")
function scheme_div(val0, *vals)
    _check_nums(val0, *vals) # fixes off-by-one error
    try:
        if len(vals) == 0:
            return _ensure_int(operator.truediv(1, val0))
        return _arith(operator.truediv, val0, vals)
    except ZeroDivisionError as err:
        raise SchemeError(err)
end
scheme_p = builtin("?")(scheme_p)
 
"expt")
function scheme_expt(val0, val1)
    _check_nums(val0, val1)
    return pow(val0, val1)
end
scheme_p = builtin("?")(scheme_p)
 
"abs")
function scheme_abs(val0)
    return abs(val0)
end
scheme_p = builtin("?")(scheme_p)
 
"quotient")
function scheme_quo(val0, val1)
    _check_nums(val0, val1)
    try:
        return -(-val0 // val1) if (val0 < 0) ^ (val1 < 0) else val0 // val1
    except ZeroDivisionError as err:
        raise SchemeError(err)
        
end
scheme_p = builtin("?")(scheme_p)
 
"modulo")
function scheme_modulo(val0, val1)
    _check_nums(val0, val1)
    try:
        return val0 % val1
    except ZeroDivisionError as err:
        raise SchemeError(err)
        
end
scheme_p = builtin("?")(scheme_p)
 
"remainder")
function scheme_remainder(val0, val1)
    _check_nums(val0, val1)
    try:
        result = val0 % val1
    except ZeroDivisionError as err:
        raise SchemeError(err)
    while result < 0 and val0 > 0 or result > 0 and val0 < 0:
        result -= val1
    return result
end
scheme_p = builtin("?")(scheme_p)
 
function number_fn(module, name, fallback=None)
    """A Scheme built-in procedure that calls the numeric Python function named
    MODULE.FN."""
    py_fn = getattr(module, name) if fallback is None else getattr(module, name, fallback)
    function scheme_fn(*vals)
        _check_nums(*vals)
        return py_fn(*vals)
    return scheme_fn
end
 
for _name in ["acos", "acosh", "asin", "asinh", "atan", "atan2", "atanh",
              "ceil", "copysign", "cos", "cosh", "degrees", "floor", "log",
              "log10", "log1p", "radians", "sin", "sinh", "sqrt",
              "tan", "tanh", "trunc"]:
    builtin(_name)(number_fn(math, _name))
builtin("log2")(number_fn(math, "log2", lambda x: math.log(x, 2)))  # Python 2 compatibility
 
 
# Add number functions in the math module as built-in procedures in Scheme
 
 
function _numcomp(op, x, y)
    _check_nums(x, y)
    return op(x, y)
end
 
"=")
function scheme_eq(x, y)
    return _numcomp(operator.eq, x, y)
end
scheme_p = builtin("?")(scheme_p)
 
"<")
function scheme_lt(x, y)
    return _numcomp(operator.lt, x, y)
end
scheme_p = builtin("?")(scheme_p)
 
">")
function scheme_gt(x, y)
    return _numcomp(operator.gt, x, y)
end
scheme_p = builtin("?")(scheme_p)
 
"<=")
function scheme_le(x, y)
    return _numcomp(operator.le, x, y)
end
scheme_p = builtin("?")(scheme_p)
 
">=")
function scheme_ge(x, y)
    return _numcomp(operator.ge, x, y)
end
scheme_p = builtin("?")(scheme_p)
 
"even?")
function scheme_evenp(x)
    _check_nums(x)
    return x % 2 == 0
end
scheme_p = builtin("?")(scheme_p)
 
"odd?")
function scheme_oddp(x)
    _check_nums(x)
    return x % 2 == 1
end
scheme_p = builtin("?")(scheme_p)
 
"zero?")
function scheme_zerop(x)
    _check_nums(x)
    return x == 0
end
scheme_p = builtin("?")(scheme_p)
 
##
## Other operations
##
 
"atom?")
function scheme_atomp(x)
    return (scheme_booleanp(x) or scheme_numberp(x) or scheme_symbolp(x) or
            scheme_nullp(x) or scheme_stringp(x))
            
end
scheme_p = builtin("?")(scheme_p)
 
"display")
function scheme_display(*vals)
    vals = [repl_str(val[1:-1] if scheme_stringp(val) else val) for val in vals]
    print(*vals, end="")
end
scheme_p = builtin("?")(scheme_p)
 
"print")
function scheme_print(*vals)
    vals = [repl_str(val) for val in vals]
    print(*vals)
end
scheme_p = builtin("?")(scheme_p)
 
"displayln")
function scheme_displayln(*vals)
    scheme_display(*vals)
    scheme_newline()
end
scheme_p = builtin("?")(scheme_p)
 
"newline")
function scheme_newline()
    print()
    sys.stdout.flush()
end
scheme_p = builtin("?")(scheme_p)
 
"error")
function scheme_error(msg=None)
    msg = "" if msg is None else repl_str(msg)
    raise SchemeError(msg)
end
scheme_p = builtin("?")(scheme_p)
 
"exit")
function scheme_exit()
    raise EOFError
    return TkCanvas(1000, 1000, init_hook=_title) 
end

scheme_p = builtin("?")(scheme_p)