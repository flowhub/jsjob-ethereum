exports.toHex = (str) ->
  a = []
  for c in str
    h = c.charCodeAt(0)
    h = "0x"+h.toString(16)
    a.push h
  return a
exports.toStr = (arr) ->
  return (String.fromCharCode(parseInt(i, 16)) for i in arr).join('')
