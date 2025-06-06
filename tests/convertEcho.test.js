const { convertEchoToInstructionsFormat } = require('../scripts/build');

describe('convertEchoToInstructionsFormat', () => {
  test('creates markdown from echo object', () => {
    const echo = {
      echo: 'Planning – Basic',
      purpose: 'Plan tasks',
      trigger: 'When planning',
      steps: ['Do A', 'Do B'],
      output: 'Structured plan'
    };
    const config = { name: 'planning', trigger: 'planning' };
    const markdown = convertEchoToInstructionsFormat(echo, config);
    expect(markdown).toContain('# Copilot Instructions: Planning – Basic');
    expect(markdown).toContain('## Purpose');
    expect(markdown).toContain('Plan tasks');
    expect(markdown).toContain('## When to Trigger');
    expect(markdown).toContain('When planning');
    expect(markdown).toContain('1. Do A');
    expect(markdown).toContain('2. Do B');
    expect(markdown).toContain('## Output Format');
    expect(markdown).toContain('Structured plan');
  });
});
