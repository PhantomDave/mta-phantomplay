function isTableNotEmpty(t)
	return type(t) == "table" and next(t) ~= nil
end
