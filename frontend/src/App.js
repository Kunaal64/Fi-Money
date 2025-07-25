import React, { useState, useEffect } from 'react';
import Login from './Login';
import Register from './Register';
import ProductList from './ProductList';
import './App.css';

function App() {
  const [page, setPage] = useState('login'); // 'login' | 'register' | 'products'
  const [token, setToken] = useState(null);

  useEffect(() => {
    if (page === 'login' || page === 'register') {
      document.body.classList.add('body-no-scroll');
    } else {
      document.body.classList.remove('body-no-scroll');
    }
    // Clean up the class when the component unmounts or page changes
    return () => {
      document.body.classList.remove('body-no-scroll');
    };
  }, [page]);

  const handleLogin = (tok) => {
    setToken(tok);
    setPage('products');
  };

  const handleRegister = () => {
    setPage('login');
  };

  const handleLogout = () => {
    setToken(null);
    setPage('login');
  };

  return (
    <div className="app-container">
      <div className="app-header-flex">
        <h1 className="app-title aesthetic-title">Fi Money Inventory</h1>
        {token && (
          <button onClick={handleLogout} className="logout-btn aesthetic-logout">Logout</button>
        )}
      </div>
      {token ? (
        <ProductList token={token} />
      ) : (
        <>
          <div style={{ textAlign: 'center', marginBottom: 15 }}>
            {page === 'login' ? (
              <>
                <span>Don't have an account?{' '}
                  <button className="link-btn" onClick={() => setPage('register')}>Register</button>
                </span>
              </>
            ) : (
              <>
                <span>Already have an account?{' '}
                  <button className="link-btn" onClick={() => setPage('login')}>Login</button>
                </span>
              </>
            )}
          </div>
          {page === 'login' ? (
            <Login onLogin={handleLogin} />
          ) : (
            <Register onRegister={handleRegister} />
          )}
        </>
      )}
    </div>
  );
}

export default App;
