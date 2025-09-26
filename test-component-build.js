const fs = require('fs');
const path = require('path');

// Read the component file
const componentPath = '/app/frontend/src/components/CaptchaProtectedContact.jsx';
const componentContent = fs.readFileSync(componentPath, 'utf8');

console.log('🧪 Testing CaptchaProtectedContact component syntax...');

// Look for problematic patterns that cause "Identifier directly after number"
const problematicPatterns = [
  /\d+[A-Za-z]/g,  // Numbers followed by letters
  /['"]\s*<\s*\d+[A-Za-z]/g,  // Quotes containing "< 10K" patterns
  /value\s*=\s*['""][^'"]*\d+[A-Za-z][^'"]*['"]/g  // value attributes with number+letter
];

let foundIssues = [];
let lineNumber = 1;

componentContent.split('\n').forEach((line, index) => {
  lineNumber = index + 1;
  
  problematicPatterns.forEach((pattern, patternIndex) => {
    const matches = line.match(pattern);
    if (matches) {
      matches.forEach(match => {
        // Skip CSS classes and other safe patterns
        if (line.includes('className') || 
            line.includes('svg') || 
            line.includes('viewBox') || 
            line.includes('fillRule') ||
            line.includes('clipRule') ||
            line.includes('strokeWidth') ||
            line.includes('reCAPTCHA') ||
            line.includes('RECAPTCHA')) {
          return; // Skip safe patterns
        }
        
        foundIssues.push({
          line: lineNumber,
          content: line.trim(),
          match: match,
          pattern: patternIndex
        });
      });
    }
  });
});

if (foundIssues.length > 0) {
  console.log('❌ Found potential syntax issues:');
  foundIssues.forEach(issue => {
    console.log(`   Line ${issue.line}: "${issue.match}" in: ${issue.content}`);
  });
  
  console.log('\n💡 Suggested fixes:');
  console.log('   - Replace "10K" with "10000" or "ten thousand"');
  console.log('   - Use only letters and numbers separated by spaces');
  console.log('   - Avoid number+letter combinations in JSX attributes');
  
} else {
  console.log('✅ No obvious syntax issues found');
}

// Check specific line 380
const lines = componentContent.split('\n');
if (lines[379]) {  // Line 380 (0-based index 379)
  console.log(`\n🔍 Line 380 content: ${lines[379]}`);
  console.log(`🔍 Character at position 44: "${lines[379][43] || 'N/A'}"`);
}

console.log('\n📊 Component stats:');
console.log(`   - Lines: ${lines.length}`);
console.log(`   - Characters: ${componentContent.length}`);
console.log(`   - Size: ${Math.round(componentContent.length / 1024)}KB`);