/**
 * Agent Loop CLI - Main entry point
 */

const path = require('path');
const os = require('os');
const fs = require('fs-extra');
const inquirer = require('inquirer');
const chalk = require('chalk');
const installer = require('./installer');

/**
 * Detect system language
 * @returns {string} 'zh' or 'en'
 */
function detectSystemLanguage() {
  const locale = os.userInfo().lang || os.platform();
  if (locale.startsWith('zh') || locale.includes('Chinese')) {
    return 'zh';
  }
  return 'en';
}

/**
 * Get localized messages
 * @param {string} lang - Language code
 */
function getMessages(lang) {
  const isZh = lang === 'zh';
  return {
    welcome: isZh
      ? '\nAgent Loop 脚手架初始化\n'
      : '\nAgent Loop Scaffold Initialization\n',
    subtitle: isZh
      ? '基于 Anthropic 官方论文 "Effective Harnesses for Long-Running Agents"'
      : 'Based on Anthropic paper "Effective Harnesses for Long-Running Agents"',
    selectingLanguage: isZh ? '选择语言' : 'Select language',
    installing: isZh ? '安装中...' : 'Installing...',
    success: isZh ? '\n初始化完成!\n' : '\nInitialization complete!\n',
    nextSteps: isZh
      ? '下一步: cd <dir> 然后运行 claude 告诉 Claude: "请读取 CLAUDE.md 和 agent-loop/feature_list.json，按优先级顺序实现所有 passes:false 的功能。测试通过后才能标记为完成，每次完成后更新进度并提交 git。"'
      : 'Next steps: cd <dir> then run claude and tell: "Please read CLAUDE.md and agent-loop/feature_list.json, implement all features with passes:false in priority order. Only mark as complete after tests pass, update progress and commit git after each completion."',
    invalidLang: isZh
      ? '无效的语言选项'
      : 'Invalid language option',
    useLang: isZh ? '请使用: --lang zh 或 --lang en' : 'Please use: --lang zh or --lang en',
    cancelled: isZh ? '安装已取消' : 'Installation cancelled',
    template: isZh ? '使用模板' : 'Using template',
    language: isZh ? '中文' : 'Chinese',
    targetDirectory: isZh ? '安装到哪个目录?' : 'Which directory to install?',
    currentDir: isZh ? '当前目录 (./)' : 'Current directory (./)',
    customDir: isZh ? '指定目录' : 'Custom directory',
    enterPath: isZh ? '请输入目录路径:' : 'Enter directory path:',
    confirmInstall: isZh ? '确认安装?' : 'Confirm installation?',
    copying: isZh ? '正在复制文件...' : 'Copying files...',
    done: isZh ? '所有文件复制完成!' : 'All files copied!',
    created: isZh ? '已创建文件结构:' : 'Created structure:',
    dirNotExist: isZh ? '目录不存在，将创建' : 'Directory not exist, will create',
    exists: isZh ? 'agent-loop/ 目录已存在，是否覆盖?' : 'agent-loop/ directory exists, overwrite?'
  };
}

/**
 * Main entry point
 */
async function init(options) {
  // Determine target directory first
  const targetDir = path.resolve(process.cwd(), options.dir || '.');

  // If language not specified, show interactive selection with auto-detected default
  let lang = options.lang;
  if (!lang) {
    const defaultLang = detectSystemLanguage();
    const msg = getMessages(defaultLang);

    console.log(chalk.cyan(msg.welcome));
    console.log(chalk.gray(msg.subtitle + '\n'));

    const answers = await inquirer.prompt([
      {
        type: 'list',
        name: 'language',
        message: msg.selectingLanguage,
        choices: [
          { name: '中文', value: 'zh' },
          { name: 'English', value: 'en' }
        ],
        default: defaultLang
      },
      {
        type: 'list',
        name: 'targetDir',
        message: msg.targetDirectory,
        choices: [
          { name: msg.currentDir, value: 'current' },
          { name: msg.customDir, value: 'custom' }
        ],
        default: 'current'
      },
      {
        type: 'confirm',
        name: 'confirm',
        message: msg.confirmInstall,
        default: true
      }
    ]);
    lang = answers.language;

    // If user selects custom directory
    if (answers.targetDir === 'custom') {
      const { customPath } = await inquirer.prompt([
        {
          type: 'input',
          name: 'customPath',
          message: getMessages(lang).enterPath
        }
      ]);
      // Update target directory if provided
    }

    // Confirm installation
    if (!answers.confirm) {
      console.log(chalk.yellow('\n' + getMessages(lang).cancelled + '\n'));
      return;
    }
  }

  // Validate language option
  if (lang && !['zh', 'en'].includes(lang)) {
    const msg = getMessages('en');
    console.error(chalk.red(`\n${msg.invalidLang}: ${lang}`));
    console.log(chalk.gray(msg.useLang + '\n'));
    process.exit(1);
  }

  const msg = getMessages(lang);

  console.log(chalk.cyan(msg.welcome));
  console.log(chalk.gray(msg.subtitle + '\n'));

  // Execute installation
  await installer.install(targetDir, lang, msg);

  console.log(chalk.green(msg.success));
  console.log(chalk.cyan(msg.nextSteps.replace('<dir>', targetDir)));
}

module.exports = init;
