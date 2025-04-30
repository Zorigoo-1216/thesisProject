// utils/salaryCalculator.js
const calculateSalary = async (job, progress) => {
    const start = new Date(progress.startedAt);
    const end = new Date(progress.endedAt || new Date());
  
    let workedHours = (end - start) / (1000 * 60 * 60);
    const breakStart = parseFloat(job.breakStartTime?.split(':')[0] || 0);
    const breakEnd = parseFloat(job.breakEndTime?.split(':')[0] || 0);
    const breakHours = breakEnd - breakStart;
    if (workedHours > breakEnd) workedHours -= breakHours;
  
    if (job.salary.type === 'hourly') {
      const baseSalary = workedHours * job.salary.amount;
      if (progress.status === 'completed' || progress.status === 'verified') {
        const transportAllowance = job.benefits.transportIncluded ? 5000 : 0;
        const mealAllowance = job.benefits.mealIncluded ? 4000 : 0;
        const gross = baseSalary + transportAllowance + mealAllowance;
        const tax = gross * 0.1;
        const insurance = gross * 0.05;
        const total = gross - tax - insurance;
        return {
          total: Math.round(total),
          breakdown: {
            baseSalary: Math.round(baseSalary),
            transportAllowance,
            mealAllowance,
            socialInsurance: Math.round(insurance),
            taxDeduction: Math.round(tax),
          },
        };
      } else {
        return {
          total: Math.round(baseSalary),
          breakdown: {
            baseSalary: Math.round(baseSalary),
            transportAllowance: 0,
            mealAllowance: 0,
            socialInsurance: 0,
            taxDeduction: 0,
          },
          message: 'Ажил үргэлжилж байна.',
        };
      }
    }
  
    if (progress.status !== 'completed' && progress.status !== 'verified') {
      return {
        total: 0,
        breakdown: {
          baseSalary: 0,
          transportAllowance: 0,
          mealAllowance: 0,
          socialInsurance: 0,
          taxDeduction: 0,
        },
        message: 'Ажил бүрэн дуусаагүй байна.',
      };
    }
  
    const base = job.salary.amount;
    const transportAllowance = job.benefits.transportIncluded ? 5000 : 0;
    const mealAllowance = job.benefits.mealIncluded ? 4000 : 0;
    const gross = base + transportAllowance + mealAllowance;
    const tax = gross * 0.1;
    const insurance = gross * 0.05;
    const total = gross - tax - insurance;
  
    return {
      total: Math.round(total),
      breakdown: {
        baseSalary: Math.round(base),
        transportAllowance,
        mealAllowance,
        socialInsurance: Math.round(insurance),
        taxDeduction: Math.round(tax),
      },
    };
  };
  
  module.exports = { calculateSalary };
  