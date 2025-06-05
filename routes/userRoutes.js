const express = require('express');
const router = express.Router();
const User = require('../models/User');

// Render profile view
router.get('/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).send('User not found');
    res.render('profile', { user });
  } catch (error) {
    res.status(400).send(error.message);
  }
});

// Render edit form
router.get('/:id/edit', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).send('User not found');
    res.render('edit', { user });
  } catch (error) {
    res.status(400).send(error.message);
  }
});

// Handle profile update
router.post('/:id/edit', async (req, res) => {
  const { name, email, bio } = req.body;
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { name, email, bio },
      { new: true, runValidators: true }
    );
    if (!user) return res.status(404).send('User not found');
    res.redirect(`/api/users/${user._id}`);
  } catch (error) {
    res.status(400).send(error.message);
  }
});

module.exports = router;
