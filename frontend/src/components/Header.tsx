import React from 'react';
import { Link } from 'react-router-dom';

const Header: React.FC = () => {
  return (
    <header className="bg-gradient-to-r from-purple-600 to-indigo-600 text-white shadow-lg">
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          <Link to="/" className="flex items-center space-x-2">
            <span className="text-2xl">🏍️</span>
            <h1 className="text-2xl font-bold">RiderHub</h1>
          </Link>
          <nav>
            <ul className="flex space-x-6">
              <li>
                <Link
                  to="/"
                  className="hover:text-purple-200 transition-colors"
                >
                  Home
                </Link>
              </li>
              <li>
                <Link
                  to="/discussions"
                  className="hover:text-purple-200 transition-colors"
                >
                  Discussions
                </Link>
              </li>
            </ul>
          </nav>
        </div>
      </div>
    </header>
  );
};

export default Header;

