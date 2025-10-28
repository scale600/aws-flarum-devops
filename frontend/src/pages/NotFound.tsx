import React from 'react';
import { Link } from 'react-router-dom';

const NotFound: React.FC = () => {
  return (
    <div className="max-w-2xl mx-auto text-center py-12">
      <div className="text-9xl font-bold text-purple-600 mb-4">404</div>
      <h1 className="text-4xl font-bold text-gray-800 mb-4">Page Not Found</h1>
      <p className="text-xl text-gray-600 mb-8">
        The page you're looking for doesn't exist or has been moved.
      </p>
      <Link to="/" className="btn-primary">
        ← Back to Home
      </Link>
    </div>
  );
};

export default NotFound;

