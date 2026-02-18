/**
 * Agent Loop CLI - Installation logic
 */

const path = require('path');
const fs = require('fs-extra');
const chalk = require('chalk');
const inquirer = require('inquirer');

/**
 * Install scaffold
 * @param {string} targetDir - Target directory
 * @param {string} lang - Language: zh | en
 * @param {object} msg - Localized messages
 */
async function install(targetDir, lang = 'zh', msg = null) {
  const isZh = lang === 'zh';
  const m = msg || {
    template: isZh ? '使用模板' : 'Using template',
    targetDir: isZh ? '目标目录' : 'Target directory',
    dirNotExist: isZh ? '目录不存在，将创建' : 'Directory not exist, will create',
    copying: isZh ? '正在复制文件...' : 'Copying files...',
    done: isZh ? '所有文件复制完成!' : 'All files copied!',
    created: isZh ? '已创建文件结构:' : 'Created structure:',
    exists: isZh ? 'agent-loop/ 目录已存在，是否覆盖?' : 'agent-loop/ directory exists, overwrite?',
    cancelled: isZh ? '安装已取消' : 'Installation cancelled'
  };

  const templateDir = path.resolve(__dirname, `../templates/${lang}`);
  const agentLoopDir = path.join(targetDir, 'agent-loop');

  console.log(chalk.gray(`${m.template}: ${isZh ? '中文' : 'English'}`));
  console.log(chalk.gray(`Target: ${targetDir}\n`));

  // 1. Check if target directory exists
  if (!fs.existsSync(targetDir)) {
    console.log(chalk.yellow(`${m.dirNotExist}: ${targetDir}`));
    fs.mkdirSync(targetDir, { recursive: true });
  }

  // 2. Check if agent-loop already exists
  if (fs.existsSync(agentLoopDir)) {
    const { confirm } = await inquirer.prompt([
      {
        type: 'confirm',
        name: 'confirm',
        message: m.exists,
        default: false
      }
    ]);
    if (!confirm) {
      console.log(chalk.yellow('\n' + m.cancelled + '\n'));
      return;
    }
  }

  // 3. Copy template files
  console.log(chalk.cyan(m.copying + '\n'));

  // 3.1 Copy agent-loop/ directory
  const templateAgentLoop = path.join(templateDir, 'agent-loop');
  if (fs.existsSync(templateAgentLoop)) {
    await fs.copy(templateAgentLoop, agentLoopDir);
    console.log(chalk.gray('  [OK] agent-loop/'));
  }

  // 3.2 Copy CLAUDE.md to root
  const templateClaudeMd = path.join(templateDir, 'CLAUDE.md');
  const targetClaudeMd = path.join(targetDir, 'CLAUDE.md');
  if (fs.existsSync(templateClaudeMd)) {
    await fs.copy(templateClaudeMd, targetClaudeMd);
    console.log(chalk.gray('  [OK] CLAUDE.md'));
  }

  // 3.3 CLAUDE-INIT.md (already in agent-loop/)
  const templateInitMd = path.join(templateAgentLoop, 'CLAUDE-INIT.md');
  if (fs.existsSync(templateInitMd)) {
    console.log(chalk.gray('  [OK] agent-loop/CLAUDE-INIT.md'));
  }

  // 3.4 CLAUDE-CODING.md (already in agent-loop/)
  const templateCodingMd = path.join(templateAgentLoop, 'CLAUDE-CODING.md');
  if (fs.existsSync(templateCodingMd)) {
    console.log(chalk.gray('  [OK] agent-loop/CLAUDE-CODING.md'));
  }

  console.log(chalk.green('\n' + m.done + '\n'));

  // 4. Show project structure
  console.log(chalk.cyan(m.created));
  console.log(chalk.gray(`  ${targetDir}/`));
  console.log(chalk.gray('  +-- CLAUDE.md'));
  console.log(chalk.gray('  +-- agent-loop/'));
  console.log(chalk.gray('      +-- CLAUDE-INIT.md'));
  console.log(chalk.gray('      +-- CLAUDE-CODING.md'));
  console.log(chalk.gray('      +-- feature_list.json'));
  console.log(chalk.gray('      +-- claude-progress.txt'));
  console.log(chalk.gray('      +-- init.sh'));
  console.log(chalk.gray('      +-- run-agent-loop.ps1\n'));
}

module.exports = { install };
