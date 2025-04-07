const jwt = require('jsonwebtoken');
const User = require('../models/User'); // хэрэглэгчийн model-оо замаар оруул

const authMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Access token not found' });
    }

    const token = authHeader.split(' ')[1];

    // JWT decode
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret123');

    // Token доторх user ID-г ашиглан хэрэглэгчийг хайж олох
    const user = await User.findById(decoded.id).select('-passwordHash');
    if (!user || user.state === 'Inactive') {
      return res.status(401).json({ error: 'Invalid or inactive user' });
    }

    req.user = {
      id: user._id,
      role: user.role,
      isVerified: user.isVerified,
    };

    next(); // дараагийн middleware эсвэл controller руу шилжүүлнэ
  } catch (err) {
    console.error(err);
    return res.status(403).json({ error: 'Invalid or expired token' });
  }
};

module.exports = authMiddleware;
