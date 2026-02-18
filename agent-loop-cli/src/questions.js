/**
 * Agent Loop CLI - Interactive questions
 */

const inquirer = require('inquirer');

// Language selection question
const languageQuestion = {
  type: 'list',
  name: 'language',
  message: 'Select language:',
  choices: [
    { name: '中文', value: 'zh' },
    { name: 'English', value: 'en' }
  ],
  default: 'zh'
};

// Target directory question
const targetDirQuestion = {
  type: 'list',
  name: 'targetDir',
  message: 'Which directory to install?',
  choices: [
    { name: 'Current directory (./)', value: 'current' },
    { name: 'Custom directory', value: 'custom' }
  ],
  default: 'current'
};

// Custom path question
const customPathQuestion = {
  type: 'input',
  name: 'customPath',
  message: 'Enter directory path:',
  validate: (input) => {
    if (!input || input.trim() === '') {
      return 'Please enter a valid directory path';
    }
    return true;
  }
};

// Confirmation question
const confirmQuestion = {
  type: 'confirm',
  name: 'confirm',
  message: 'Confirm installation?',
  default: true
};

module.exports = {
  language: languageQuestion,
  targetDir: targetDirQuestion,
  customPath: customPathQuestion,
  confirm: confirmQuestion
};
