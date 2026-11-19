const fail = (res, status, code, message) =>
  res.status(status).json({ success: false, error: { code, message } });

const validate = (schema) => (req, res, next) => {
  const p = schema.safeParse(req.body);
  if (!p.success) return fail(res, 400, 'VALIDATION_ERROR', p.error.issues[0].message);
  req.body = p.data;
  next();
};

module.exports = { fail, validate };