# RiderHub Frontend

Modern React-based frontend for the RiderHub Flarum community forum.

## 🚀 Features

- **Modern UI**: Built with React 18 and TypeScript
- **Responsive Design**: TailwindCSS for beautiful, mobile-first design
- **State Management**: TanStack Query for efficient server state management
- **Routing**: React Router for seamless navigation
- **API Integration**: Axios for HTTP requests to Flarum backend
- **Build Tool**: Vite for fast development and optimized builds

## 📋 Prerequisites

- Node.js >= 18.0.0
- npm >= 9.0.0

## 🛠️ Installation

```bash
# Install dependencies
npm install
```

## 🏃 Development

```bash
# Start development server
npm run dev

# The app will be available at http://localhost:3000
```

## 🏗️ Build

```bash
# Build for production
npm run build

# Preview production build
npm run preview
```

## 🧹 Code Quality

```bash
# Run ESLint
npm run lint

# Format code with Prettier
npm run format
```

## 📁 Project Structure

```
frontend/
├── src/
│   ├── components/     # Reusable UI components
│   │   ├── Header.tsx
│   │   └── Footer.tsx
│   ├── pages/          # Page components
│   │   ├── Home.tsx
│   │   ├── Discussions.tsx
│   │   └── NotFound.tsx
│   ├── App.tsx         # Main application component
│   ├── main.tsx        # Application entry point
│   └── index.css       # Global styles
├── public/             # Static assets
├── package.json        # Dependencies and scripts
├── tsconfig.json       # TypeScript configuration
├── vite.config.ts      # Vite configuration
└── README.md          # This file
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the frontend directory:

```env
VITE_API_URL=https://your-api-gateway-url.amazonaws.com/production
```

### API Proxy

The Vite development server is configured to proxy `/api` requests to the backend API. Update the proxy target in `vite.config.ts` if needed.

## 🎨 Styling

This project uses TailwindCSS for styling. Custom utilities and components are defined in `src/index.css`.

### Custom Classes

- `btn-primary`: Primary button style
- `btn-secondary`: Secondary button style
- `card`: Card container style

## 📦 Deployment

### AWS Amplify (Recommended)

1. Connect your GitHub repository to AWS Amplify
2. Configure build settings:
   - Build command: `npm run build`
   - Output directory: `dist`
3. Deploy automatically on push to main branch

### Manual Deployment

```bash
# Build the project
npm run build

# Upload the dist/ folder to your hosting provider
```

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Run linting and tests
4. Submit a pull request

## 📝 License

MIT License - see LICENSE file for details

