#!/usr/bin/env node

/**
 * Agent Loop CLI - Entry point
 * Usage: npx agent-loop init [--lang zh|en]
 */

const { program } = require('commander');
const init = require('../src/index');

program
  .name('agent-loop')
  .description('Long-Running Agent Loop Framework CLI')
  .version('1.0.0');

program
  .command('init')
  .description('Initialize Agent Loop scaffold')
  .option('-l, --lang <lang>', 'Language: zh (Chinese) / en (English)', '')
  .option('-d, --dir <path>', 'Target directory', '.')
  .action(async (options) => {
    try {
      await init(options);
    } catch (error) {
      console.error('Error:', error.message);
      process.exit(1);
    }
  });

program.parse();
