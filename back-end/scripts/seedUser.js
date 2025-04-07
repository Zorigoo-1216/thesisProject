const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const { faker } = require('@faker-js/faker');
const User = require('../models/User'); // Таны моделийн замыг шалгана уу

mongoose.connect('mongodb://localhost:27017/jobmatching');

// Branch & Skill config
const BRANCH_SKILLS = {
  "Авто үйлчилгээ, засвар": ["Тос солих", "Дугуй засвар", "Механик оношилгоо", "Гагнуур хийх"],
  "Аялал жуулчлал": ["Аяллын хөтөч", "Гадаад хэл", "Зочин угтах", "Фото зураг авах"],
  "Гоо сайхан, фитнесс, спорт": ["Иог заах", "Массаж", "Арьс арчилгаа", "Фитнесс дасгалжуулалт"],
  "Барилга дэд бүтэц": ["Хана өрөх", "Цахилгааны угсралт", "Сантехник", "Гипсэн хана"],
  "Цэвэрлэгээ": ["Шал угаах", "Шороо арчих", "Цонх угаах", "Гэр цэвэрлэх"],
  "Нүүлгэлт": ["Ачаа өргөх", "Зөөвөр хийх", "Хүнд ачаа зохион байгуулах"],
  "Худалдаа үйлчилгээний туслах": ["Тавиур өрөх", "Касс хийх", "Бараа хүлээн авах"],
  "Ресторан, кафе, паб": ["Зөөгч", "Гал тогооны туслах", "Сав суулга угаах", "Касс"],
  "Цэцэрлэгжүүлэлт": ["Ногоо тарих", "Хөрс боловсруулах", "Ургамал арчлах"],
  "Тээврийн туслах": ["Ачаа тээвэрлэх", "Зам заах", "Тээврийн бичиг баримт"],
  "Үйлчилгээний туслах": ["Хэрэглэгчтэй харилцах", "Хүлээн авалт", "Зааварчилгаа өгөх"],
  "Автомашин угаалга": ["Машин угаах", "Интерьер цэвэрлэх", "Хуурай угаалга"],
  "Засварын туслах": ["Багаж барих", "Засварын тусламж", "Материал зөөвөрлөх"],
  "Эвент туслах": ["Тавилга угсрах", "Тоног төхөөрөмж угсрах", "Үйл ажиллагаанд туслах"],
  "Сурталчилгааны ажил": ["Сурталчилгаа тараах", "Хэвлэл материал түгээх", "Сошиал медиа контент"],
  "Тэжээвэр амьтны асаргаа": ["Амьтан угаах", "Тэжээл өгөх", "Аялалд дагалдах"],
  "Асрагч": ["Хүүхэд асрах", "Өндөр настан асрах", "Эмнэлгийн анхан шатны тусламж"],
  "Гэрийн үйлчлэгч": ["Гэрийн ажил хийх", "Гэр цэвэрлэх", "Гал тогоонд туслах"],
  "Гар урлал, баглаа боодол": ["Бэлэг боох", "Гар урлал хийх", "Сайхан боодол хийх"],
  "Гэрийн тохижилт": ["Тавилга зөөх", "Будгийн ажил", "Хөшиг тогтоох"],
  "Улирлын ажил (цас, наадам)": ["Цас цэвэрлэх", "Наадамд туслах", "Лангуу барих"],
  "Туршилт, судалгаа": ["Судалгаанд оролцох", "Туршилт хийх", "Бичиг баримт бөглөх"]
};

const generateSkillsByBranch = (branch) => {
  const allSkills = BRANCH_SKILLS[branch] || [];
  const count = Math.floor(Math.random() * 2) + 1; // 1-2 skills
  return faker.helpers.shuffle(allSkills).slice(0, count);
};

const generateUser = async () => {
    const branchType = faker.helpers.arrayElement(Object.keys(BRANCH_SKILLS));
    const skills = generateSkillsByBranch(branchType);
  
    return {
      _id: new mongoose.Types.ObjectId(),
      firstName: faker.person.firstName(),
      lastName: faker.person.lastName(),
      phone: faker.phone.number('8########'),
      email: faker.internet.email(),
      passwordHash: await bcrypt.hash('password123', 10),
      role: 'individual',
      gender: faker.helpers.arrayElement(['male', 'female']),
      isVerified: true,
      state: 'Active',
      lastActiveAt: new Date(),
      createdAt: new Date(),
      updatedAt: new Date(),
      profile: {
        birthDate: faker.date.past({ years: 30, refDate: '2005-01-01' }),
        identityNumber: faker.string.alpha({ length: 2 }) + faker.number.int({ min: 1000000, max: 9999999 }),
        location: faker.location.city(),
        mainBranch: branchType,
        waitingSalaryPerHour: faker.number.int({ min: 5000, max: 10000 }),
        driverLicense: faker.datatype.boolean() ? ['B'] : [],
        skills,
        additionalSkills: faker.helpers.arrayElements(['Харилцааны чадвар', 'Хурдан хөдөлгөөнтэй', 'Цэвэрч'], 2),
        experienceLevel: faker.helpers.arrayElement(['beginner', 'intermediate', 'expert']),
        languageSkills: faker.helpers.arrayElements(['Mongolian', 'English', 'Russian'], 1),
        isDisabledPerson: faker.datatype.boolean()
      },
      averageRating: {
        overall: faker.number.float({ min: 3, max: 5, precision: 0.1 }),
        byBranch: {
          Cleaning: 0,
          Building: 0,
          Transport: 0
        }
      }
    };
  };
  

const insertUsers = async (count = 20) => {
  const users = [];
  for (let i = 0; i < count; i++) {
    const user = await generateUser();
    users.push(user);
  }
  await User.insertMany(users);
  console.log(`${count} хэрэглэгч амжилттай нэмэгдлээ.`);
  mongoose.disconnect();
};

insertUsers(20);
