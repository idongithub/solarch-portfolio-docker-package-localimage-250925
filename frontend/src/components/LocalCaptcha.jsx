import React, { useState, useEffect } from 'react';

const LocalCaptcha = ({ onCaptchaChange, isValid, setIsValid }) => {
  const [question, setQuestion] = useState('');
  const [answer, setAnswer] = useState('');
  const [userAnswer, setUserAnswer] = useState('');
  const [captchaId, setCaptchaId] = useState('');

  // Generate simple math captcha
  const generateCaptcha = () => {
    const num1 = Math.floor(Math.random() * 10) + 1;
    const num2 = Math.floor(Math.random() * 10) + 1;
    const operations = ['+', '-', '×'];
    const operation = operations[Math.floor(Math.random() * operations.length)];
    
    let correctAnswer;
    let questionText;
    
    switch(operation) {
      case '+':
        correctAnswer = num1 + num2;
        questionText = `${num1} + ${num2}`;
        break;
      case '-':
        // Ensure positive result
        const larger = Math.max(num1, num2);
        const smaller = Math.min(num1, num2);
        correctAnswer = larger - smaller;
        questionText = `${larger} - ${smaller}`;
        break;
      case '×':
        correctAnswer = num1 * num2;
        questionText = `${num1} × ${num2}`;
        break;
      default:
        correctAnswer = num1 + num2;
        questionText = `${num1} + ${num2}`;
    }
    
    const id = Date.now().toString();
    setQuestion(questionText);
    setAnswer(correctAnswer.toString());
    setCaptchaId(id);
    setUserAnswer('');
    setIsValid(false);
    
    // Return captcha data for backend verification
    return {
      captcha_id: id,
      captcha_question: questionText,
      captcha_answer: correctAnswer.toString()
    };
  };

  // Initialize captcha on component mount
  useEffect(() => {
    const captchaData = generateCaptcha();
    onCaptchaChange(captchaData);
  }, []);

  // Handle user input
  const handleAnswerChange = (e) => {
    const value = e.target.value;
    setUserAnswer(value);
    
    const isCorrect = value.trim() === answer;
    setIsValid(isCorrect);
    
    // Notify parent component
    onCaptchaChange({
      captcha_id: captchaId,
      captcha_question: question,
      captcha_answer: answer,
      user_answer: value,
      is_valid: isCorrect
    });
  };

  // Refresh captcha
  const refreshCaptcha = () => {
    const captchaData = generateCaptcha();
    onCaptchaChange(captchaData);
  };

  return (
    <div className="local-captcha bg-gray-50 p-4 rounded-lg border">
      <label className="block text-sm font-medium text-gray-700 mb-2">
        Security Verification (Local)
      </label>
      
      <div className="flex items-center space-x-3 mb-3">
        <div className="bg-white px-3 py-2 border rounded font-mono text-lg border-gray-300">
          {question} = ?
        </div>
        <button
          type="button"
          onClick={refreshCaptcha}
          className="text-blue-600 hover:text-blue-800 text-sm underline"
          title="Generate new question"
        >
          🔄 Refresh
        </button>
      </div>
      
      <input
        type="text"
        value={userAnswer}
        onChange={handleAnswerChange}
        placeholder="Enter your answer"
        className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent ${
          userAnswer ? (isValid ? 'border-green-500 bg-green-50' : 'border-red-500 bg-red-50') : 'border-gray-300'
        }`}
        autoComplete="off"
      />
      
      {userAnswer && (
        <div className={`mt-2 text-sm ${isValid ? 'text-green-600' : 'text-red-600'}`}>
          {isValid ? '✅ Correct!' : '❌ Incorrect, please try again'}
        </div>
      )}
      
      <div className="text-xs text-gray-500 mt-2">
        Local verification for IP-based access
      </div>
    </div>
  );
};

export default LocalCaptcha;