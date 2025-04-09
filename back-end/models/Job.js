const mongoose = require('mongoose');

const jobSchema = new mongoose.Schema({
  employerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },

  // Ерөнхий мэдээлэл
  title: { type: String, required: true },
  description: { type: [String], default: [] },             // Ажлын тодорхойлолт
  requirements: { type: [String], default: [] },            // Шаардлагууд
  location: { type: String, required: true },               // Байршил

  // Цалин
  salary: {
    amount: { type: Number, required: true },
    currency: { type: String, default: 'MNT' },
    type: { type: String, enum: ['daily', 'hourly'], required: true }
  },

  // Нэмэлт урамшуулал
  benefits: {
    transportIncluded: { type: Boolean, default: false },
    mealIncluded: { type: Boolean, default: false },
    bonusIncluded: { type: Boolean, default: false }
  },

  seeker: { type: String, enum: ['individual', 'company'], required: true },  // Зорилтот ажил горилогч
  capacity: { type: Number, required: true },                                  // Ажилчдын тоо
  branch: { type: String, enum: ['Cleaning', 'Building', 'Transport'], required: true },
  jobType: { type: String, enum: ['hourly', 'part_time', 'full_time'], required: true },
  level: { type: String, enum: ['none', 'mid', 'high'], default: 'none' },
  possibleForDisabled: { type: Boolean, default: false },

  // Ажлын төлөв, хугацаа
  status: {
    type: String,
    enum: ['open', 'closed', 'working', 'deleted', 'completed'],
    default: 'open'
  },
  startDate: { type: Date, required: true },         // Гэрээт ажлын эхлэх огноо
  endDate: { type: Date, required: true },           // Гэрээт ажлын дуусах огноо

  // Ажлын өдөр дэх цагийн хуваарь
  workStartTime: { type: String, required: true },   // Жишээ: "08:00"
  workEndTime: { type: String, required: true },     // Жишээ: "17:00"
  breakStartTime: { type: String },                  // Жишээ: "12:00"
  breakEndTime: { type: String },                    // Жишээ: "13:00"

  // Бусад мэдээлэл
  haveInterview: { type: Boolean, default: false },

  employees: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],         // Сонгогдсон ажилчид
  applications: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Application' }], // Бүх өргөдөл

  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date },
  endedAt: { type: Date }
});

module.exports = mongoose.model('Job', jobSchema);
