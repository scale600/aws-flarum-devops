import React from 'react';

const Footer: React.FC = () => {
  return (
    <footer className="bg-gray-800 text-white py-6 mt-8">
      <div className="container mx-auto px-4">
        <div className="flex flex-col md:flex-row justify-between items-center">
          <div className="mb-4 md:mb-0">
            <p className="text-sm">
              © {new Date().getFullYear()} RiderHub. All rights reserved.
            </p>
          </div>
          <div className="flex space-x-4">
            <a
              href="https://github.com/scale600/aws-flarum-devops"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-purple-400 transition-colors"
            >
              GitHub
            </a>
            <a
              href="/api"
              className="hover:text-purple-400 transition-colors"
            >
              API Docs
            </a>
          </div>
        </div>
        <div className="mt-4 text-center text-sm text-gray-400">
          <p>Powered by AWS Lambda • Built with React & Flarum</p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;

