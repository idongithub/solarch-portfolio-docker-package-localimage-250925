# Contributing to Kamal Singh Portfolio

Thank you for your interest in contributing to this professional portfolio project!

## 🚀 Getting Started

### Prerequisites
- Node.js 16+ 
- Python 3.8+
- MongoDB 4.4+
- Yarn package manager

### Setup Development Environment

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/kamal-singh-portfolio.git
cd kamal-singh-portfolio
```

2. **Run automated setup**
```bash
chmod +x setup.sh
./setup.sh
```

3. **Start development servers**
```bash
./start_portfolio.sh
```

## 🎯 Project Structure

```
kamal-singh-portfolio/
├── backend/          # FastAPI backend
├── frontend/         # React frontend
├── setup.sh         # Automated setup
├── start_portfolio.sh # Start services
└── stop_portfolio.sh  # Stop services
```

## 🛠️ Technology Stack

### Frontend
- **React 19** - UI framework
- **Tailwind CSS** - Styling
- **Shadcn/UI** - Component library
- **React Router** - Navigation
- **Lucide React** - Icons

### Backend
- **FastAPI** - Python web framework
- **MongoDB** - Database
- **Motor** - Async MongoDB driver
- **Pydantic** - Data validation

## 📝 Development Guidelines

### Code Style

#### Frontend (React/JavaScript)
- Use functional components with hooks
- Follow React best practices
- Use Tailwind CSS for styling
- Maintain consistent naming conventions
- Use TypeScript-style prop validation

#### Backend (Python)
- Follow PEP 8 style guidelines
- Use type hints where appropriate
- Write async functions for database operations
- Maintain clear API documentation

### Commit Messages
Use conventional commit format:
```
feat: add new testimonials section
fix: resolve header visibility issue
docs: update deployment guide
style: improve mobile responsiveness
```

### Branch Naming
- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `style/description` - UI/UX improvements

## 🧪 Testing

### Frontend Testing
```bash
cd frontend
yarn test
```

### Backend Testing
```bash
cd backend
source venv/bin/activate
python -m pytest
```

### Integration Testing
```bash
# Test full application
./start_portfolio.sh
# Verify at http://localhost:3000
./stop_portfolio.sh
```

## 📦 Making Changes

### 1. Create Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes
- Follow the coding guidelines
- Test your changes locally
- Update documentation if needed

### 3. Test Changes
```bash
# Test frontend
cd frontend && yarn build

# Test backend
cd backend && source venv/bin/activate && python -c "from server import app"

# Test full application
./start_portfolio.sh
```

### 4. Commit and Push
```bash
git add .
git commit -m "feat: description of your changes"
git push origin feature/your-feature-name
```

### 5. Create Pull Request
- Provide clear description of changes
- Include screenshots for UI changes
- Reference any related issues

## 🎨 Design Guidelines

### UI/UX Principles
- **Corporate Professional Theme** - Navy, charcoal, gold colors
- **Professional Typography** - Georgia serif fonts
- **Responsive Design** - Mobile-first approach
- **Accessibility** - WCAG 2.1 AA compliance
- **Performance** - Optimize images and loading times

### Component Guidelines
- Use Shadcn/UI components when possible
- Maintain consistent spacing and sizing
- Follow established color scheme
- Ensure proper hover states and animations

## 🐛 Reporting Issues

### Bug Reports
Include:
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots if applicable
- Environment details (OS, browser, versions)

### Feature Requests
Include:
- Clear description of the feature
- Use case and benefits
- Mockups or examples if applicable

## 📋 Pull Request Process

1. **Pre-submission Checklist**
   - [ ] Code follows style guidelines
   - [ ] All tests pass
   - [ ] Documentation updated
   - [ ] No console errors
   - [ ] Mobile responsive

2. **Review Process**
   - Automated CI checks must pass
   - Code review by maintainer
   - Testing on different environments
   - Approval and merge

## 🔒 Security

### Reporting Security Issues
- **DO NOT** create public issues for security vulnerabilities
- Email security concerns privately
- Provide detailed reproduction steps
- Allow reasonable time for response

### Security Guidelines
- Never commit sensitive data (API keys, passwords)
- Use environment variables for configuration
- Follow secure coding practices
- Keep dependencies updated

## 📞 Getting Help

### Questions or Issues?
- Check existing [GitHub Issues](https://github.com/yourusername/kamal-singh-portfolio/issues)
- Create new issue with detailed description
- Use appropriate labels (bug, feature, question)

### Professional Contact
This portfolio represents **Kamal Singh**:
- **Email**: chkamalsingh@yahoo.com
- **Location**: Amersham, United Kingdom
- **Specialization**: Enterprise Architecture & Digital Transformation

## 📄 License

This project is maintained as a professional portfolio. Please respect the intellectual property and personal information contained within.

## 🙏 Acknowledgments

- **Shadcn/UI** for the component library
- **Tailwind CSS** for the styling framework
- **Lucide React** for the icon system
- **FastAPI** for the backend framework
- **React** for the frontend framework

---

**Thank you for contributing to this professional portfolio project!** 🎉