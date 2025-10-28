import React from 'react';
import { Link } from 'react-router-dom';

const Home: React.FC = () => {
  return (
    <div className="max-w-4xl mx-auto">
      <div className="text-center mb-12">
        <h1 className="text-5xl font-bold text-gray-800 mb-4">
          Welcome to RiderHub 🏍️
        </h1>
        <p className="text-xl text-gray-600">
          Your motorcycle community forum powered by AWS serverless technology
        </p>
      </div>

      <div className="grid md:grid-cols-3 gap-6 mb-12">
        <div className="card hover:shadow-lg transition-shadow">
          <div className="text-3xl mb-3">💬</div>
          <h3 className="text-xl font-bold mb-2">Discussions</h3>
          <p className="text-gray-600">
            Engage in meaningful conversations with fellow riders
          </p>
        </div>

        <div className="card hover:shadow-lg transition-shadow">
          <div className="text-3xl mb-3">🛠️</div>
          <h3 className="text-xl font-bold mb-2">Gear Reviews</h3>
          <p className="text-gray-600">
            Share and discover the best motorcycle gear
          </p>
        </div>

        <div className="card hover:shadow-lg transition-shadow">
          <div className="text-3xl mb-3">🗺️</div>
          <h3 className="text-xl font-bold mb-2">Route Planning</h3>
          <p className="text-gray-600">
            Find and share amazing riding routes
          </p>
        </div>
      </div>

      <div className="card bg-gradient-to-r from-purple-100 to-indigo-100">
        <h2 className="text-2xl font-bold mb-4">Built with Modern Technology</h2>
        <ul className="space-y-2 text-gray-700">
          <li>✅ AWS Lambda for serverless compute</li>
          <li>✅ RDS MySQL for reliable data storage</li>
          <li>✅ S3 for scalable file storage</li>
          <li>✅ React for modern UI</li>
          <li>✅ Terraform for infrastructure as code</li>
          <li>✅ GitHub Actions for CI/CD</li>
        </ul>
        <div className="mt-6">
          <Link to="/discussions" className="btn-primary">
            Explore Discussions →
          </Link>
        </div>
      </div>
    </div>
  );
};

export default Home;

