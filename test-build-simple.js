// Simple test to validate JSX syntax
const fs = require('fs');

const componentContent = fs.readFileSync('/app/frontend/src/components/CaptchaProtectedContact.jsx', 'utf8');

// Check for the most common JSX syntax issues
const syntaxChecks = [
  {
    name: 'Balanced JSX tags',
    test: (content) => {
      const openTags = (content.match(/<[^/][^>]*>/g) || []).length;
      const closeTags = (content.match(/<\/[^>]*>/g) || []).length;
      const selfClosingTags = (content.match(/<[^>]*\/>/g) || []).length;
      return openTags === closeTags + selfClosingTags;
    }
  },
  {
    name: 'Valid attribute quotes',
    test: (content) => {
      // Check for unclosed quotes in attributes
      const lines = content.split('\n');
      return !lines.some(line => {
        if (line.includes('=') && (line.includes('"') || line.includes("'"))) {
          const quotes = line.match(/["']/g) || [];
          return quotes.length % 2 !== 0;
        }
        return false;
      });
    }
  },
  {
    name: 'No number-letter combinations in values',
    test: (content) => {
      // Look for value="...10K..." patterns that cause issues
      const problematic = content.match(/value\s*=\s*["'][^"']*\d+[A-Za-z][^"']*["']/g);
      return !problematic || problematic.length === 0;
    }
  }
];

console.log('🔍 Running JSX Syntax Checks...');
console.log('================================');

let allPassed = true;

syntaxChecks.forEach(check => {
  const passed = check.test(componentContent);
  console.log(`${passed ? '✅' : '❌'} ${check.name}: ${passed ? 'PASS' : 'FAIL'}`);
  if (!passed) allPassed = false;
});

console.log('\n📊 Final Result:');
console.log(`${allPassed ? '🎉 All checks passed!' : '⚠️  Some checks failed'}`);

if (allPassed) {
  console.log('✅ Component should build successfully');
} else {
  console.log('❌ Component may have build issues');
}

// Show the budget section specifically
const lines = componentContent.split('\n');
const budgetStart = lines.findIndex(line => line.includes('Budget Range'));
if (budgetStart > 0) {
  console.log('\n💰 Budget Options Section:');
  for (let i = budgetStart; i < Math.min(budgetStart + 15, lines.length); i++) {
    if (lines[i].includes('option value')) {
      console.log(`   ${lines[i].trim()}`);
    }
  }
}