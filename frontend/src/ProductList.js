import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { FaTrash } from 'react-icons/fa';

const DEFAULT_IMAGE = "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='60' height='60'><rect width='100%' height='100%' fill='%23ccc'/><text x='50%' y='50%' dominant-baseline='middle' text-anchor='middle' fill='%23666' font-size='10'>No Img</text></svg>";

export default function ProductList({ token }) {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [form, setForm] = useState({ name: '', type: '', sku: '', image_url: '', description: '', quantity: '', price: '' });
  const [addError, setAddError] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [editingQty, setEditingQty] = useState('');
  const [deleteId, setDeleteId] = useState(null);
  const [mostAdded, setMostAdded] = useState([]);

  const loadProducts = async () => {
    setLoading(true);
    try {
      const res = await axios.get('http://localhost:8080/products');
      setProducts(res.data);
    } catch (err) {
      setError('Failed to load products');
    }
    setLoading(false);
  };

  const handleAdd = async (e) => {
    e.preventDefault();
    setAddError('');
    try {
      const response = await axios.post('http://localhost:8080/products', {
        ...form,
        quantity: Number(form.quantity),
        price: Number(form.price)
      });
      loadMostAdded(); // Call loadMostAdded after a product is added

      setForm({ name: '', type: '', sku: '', image_url: '', description: '', quantity: '', price: '' });
      setShowModal(false);
      loadProducts();
    } catch (err) {
      setAddError(err.response?.data?.error || 'Add failed');
    }
  };

  const loadMostAdded = async () => {
    try {
      const res = await axios.get('http://localhost:8080/products/analytics/most-added');
      setMostAdded(res.data);
    } catch (err) {
      console.error('Failed to load most added products analytics:', err);
    }
  };

  useEffect(() => {
    if (token) {
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    }
    loadProducts();
    loadMostAdded(); // Load analytics on component mount
    // eslint-disable-next-line
  }, [token]);

  const handleQtyClick = (id, currentQty) => {
    setEditingId(id);
    setEditingQty(currentQty);
  };

  const handleQtyChange = (e) => {
    setEditingQty(e.target.value);
  };

  const handleQtyBlurOrEnter = async (id) => {
    if (editingQty === '' || isNaN(Number(editingQty))) {
      setEditingId(null);
      return;
    }
    try {
      await axios.put(`http://localhost:8080/products/${id}/quantity`, { quantity: Number(editingQty) });
      setProducts(products => products.map(p => p.id === id ? { ...p, quantity: Number(editingQty) } : p));
      setEditingId(null);
    } catch (err) {
      alert('Update failed');
      setEditingId(null);
    }
  };

  const handleDelete = async (id) => {
    try {
      await axios.delete(`http://localhost:8080/products/${id}`);
      setProducts(products => products.filter(p => p.id !== id));
      setDeleteId(null);
    } catch (err) {
      alert('Delete failed');
      setDeleteId(null);
    }
  };

  if (loading) return <div className="centered-page"><div>Loading...</div></div>;
  if (error) return <div className="centered-page"><div className="error-message">{error}</div></div>;

  return (
    <div className="product-list-card">
      <h2 className="product-list-title">Products</h2>
      <button className="product-btn" onClick={() => setShowModal(true)}>Add Product</button>

      {mostAdded.length > 0 && (
        <div className="analytics-section">
          <h3>Most Added Products</h3>
          <ul>
            {mostAdded.map((p) => (
              <li key={p.id}>{p.name} ({p.times_added})</li>
            ))}
          </ul>
        </div>
      )}

      <table className="product-table">
        <thead>
          <tr>
            <th>Image</th>
            <th>Name</th>
            <th>Type</th>
            <th>SKU</th>
            <th>Description</th>
            <th>Quantity</th>
            <th>Price</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {products.map(p => (
            <tr key={p.id}>
              <td>
                <img
                  src={p.image_url ? p.image_url : DEFAULT_IMAGE}
                  alt={p.name}
                  onError={e => { e.target.onerror = null; e.target.src = DEFAULT_IMAGE; }}
                />
              </td>
              <td>{p.name}</td>
              <td>{p.type}</td>
              <td>{p.sku}</td>
              <td>
                {p.description ? p.description : 'No description'}
              </td>
              <td>
                {editingId === p.id ? (
                  <input
                    type="number"
                    value={editingQty}
                    autoFocus
                    className="product-input"
                    onChange={handleQtyChange}
                    onBlur={() => handleQtyBlurOrEnter(p.id)}
                    onKeyDown={e => {
                      if (e.key === 'Enter') {
                        e.preventDefault();
                        handleQtyBlurOrEnter(p.id);
                      } else if (e.key === 'Escape') {
                        setEditingId(null);
                      }
                    }}
                  />
                ) : (
                  <span onClick={() => handleQtyClick(p.id, p.quantity)} title="Click to edit">
                    {p.quantity}
                  </span>
                )}
              </td>
              <td>{Number(p.price).toLocaleString(undefined, { minimumFractionDigits: 2 })}</td>
              <td>
                <button
                  className="delete-btn"
                  title="Delete product"
                  onClick={() => setDeleteId(p.id)}
                >
                  <FaTrash />
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal-card" onClick={e => e.stopPropagation()}>
            <h3>Add Product</h3>
            <form onSubmit={handleAdd} className="add-product-form">
              <input placeholder="Name" value={form.name} onChange={e => setForm(f => ({ ...f, name: e.target.value }))} required className="product-input" />
              <input placeholder="Type" value={form.type} onChange={e => setForm(f => ({ ...f, type: e.target.value }))} required className="product-input" />
              <input placeholder="SKU" value={form.sku} onChange={e => setForm(f => ({ ...f, sku: e.target.value }))} required className="product-input" />
              <input placeholder="Image URL" value={form.image_url} onChange={e => setForm(f => ({ ...f, image_url: e.target.value }))} className="product-input full-width" />
              <input placeholder="Description" value={form.description} onChange={e => setForm(f => ({ ...f, description: e.target.value }))} className="product-input full-width" />
              <input placeholder="Quantity" type="number" value={form.quantity} onChange={e => setForm(f => ({ ...f, quantity: e.target.value }))} required className="product-input" />
              <input placeholder="Price" type="number" value={form.price} onChange={e => setForm(f => ({ ...f, price: e.target.value }))} required className="product-input" />
              {addError && <span className="error-message">{addError}</span>}
              <div className="button-group">
                <button type="submit" className="product-btn">Add</button>
                <button type="button" className="product-btn cancel-btn" onClick={() => setShowModal(false)}>Cancel</button>
              </div>
            </form>
          </div>
        </div>
      )}
      {deleteId && (
        <div className="modal-overlay" onClick={() => setDeleteId(null)}>
          <div className="modal-card" onClick={e => e.stopPropagation()}>
            <h3>Delete Product</h3>
            <p>Are you sure you want to delete this product?</p>
            <div>
              <button className="product-btn delete-confirm-btn" onClick={() => handleDelete(deleteId)}>Delete</button>
              <button className="product-btn" onClick={() => setDeleteId(null)}>Cancel</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
} 