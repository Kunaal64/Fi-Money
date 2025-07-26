import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { FaTrash } from 'react-icons/fa';

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || 'http://localhost:8080';

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

  const loadProducts = async () => {
    setLoading(true);
    try {
      const res = await axios.get(`${API_BASE_URL}/products`);
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
      const response = await axios.post(`${API_BASE_URL}/products`, {
        ...form,
        quantity: Number(form.quantity),
        price: Number(form.price)
      });

      setForm({ name: '', type: '', sku: '', image_url: '', description: '', quantity: '', price: '' });
      setShowModal(false);
      loadProducts();
    } catch (err) {
      setAddError(err.response?.data?.error || 'Add failed');
    }
  };

  useEffect(() => {
    if (token) {
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    }
    loadProducts();
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
      await axios.put(`${API_BASE_URL}/products/${id}/quantity`, { quantity: Number(editingQty) });
      setProducts(products => products.map(p => p.id === id ? { ...p, quantity: Number(editingQty) } : p));
      setEditingId(null);
    } catch (err) {
      alert('Update failed');
      setEditingId(null);
    }
  };

  const handleDelete = async (id) => {
    try {
      await axios.delete(`${API_BASE_URL}/products/${id}`);
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
          {products.map((product) => (
            <tr key={product.id}>
              <td><img src={product.image_url || DEFAULT_IMAGE} alt={product.name} className="product-thumbnail" /></td>
              <td>{product.name}</td>
              <td>{product.type}</td>
              <td>{product.sku}</td>
              <td>{product.description}</td>
              <td
                onDoubleClick={() => handleQtyClick(product.id, product.quantity)}
                className="quantity-cell"
              >
                {editingId === product.id ? (
                  <input
                    type="number"
                    value={editingQty}
                    onChange={handleQtyChange}
                    onBlur={() => handleQtyBlurOrEnter(product.id)}
                    onKeyPress={(e) => { if (e.key === 'Enter') handleQtyBlurOrEnter(product.id); }}
                    autoFocus
                    className="quantity-input"
                  />
                ) : (
                  product.quantity
                )}
              </td>
              <td>Rs{product.price ? parseFloat(product.price).toFixed(2) : '0.00'}</td>
              <td>
                <button onClick={() => setDeleteId(product.id)} className="delete-btn">
                  <FaTrash />
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {products.length === 0 && !loading && !error && (
        <div className="no-products-message">
          No products found. Add some products to get started!
        </div>
      )}

      {deleteId && (
        <div className="modal-overlay">
          <div className="modal-card">
            <h3>Confirm Delete</h3>
            <p>Are you sure you want to delete this product?</p>
            <div className="button-group">
              <button onClick={() => handleDelete(deleteId)} className="product-btn delete-btn">Delete</button>
              <button onClick={() => setDeleteId(null)} className="product-btn cancel-btn">Cancel</button>
            </div>
          </div>
        </div>
      )}

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
              {addError && <span className="error-message">{Array.isArray(addError) ? addError[0].msg : addError}</span>}
              <div className="button-group">
                <button type="submit" className="product-btn">Add</button>
                <button type="button" className="product-btn cancel-btn" onClick={() => setShowModal(false)}>Cancel</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}