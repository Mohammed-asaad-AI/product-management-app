from flask import Blueprint, request, jsonify
from src.models.product import Product, db
from decimal import Decimal, InvalidOperation

product_bp = Blueprint('product', __name__)

@product_bp.route('/products', methods=['GET'])
def get_products():
    """Get all products"""
    try:
        products = Product.query.all()
        return jsonify([product.to_dict() for product in products]), 200
    except Exception as e:
        return jsonify({'error': 'Failed to fetch products', 'message': str(e)}), 500

@product_bp.route('/products/<int:product_id>', methods=['GET'])
def get_product(product_id):
    """Get a specific product by ID"""
    try:
        product = Product.query.get_or_404(product_id)
        return jsonify(product.to_dict()), 200
    except Exception as e:
        return jsonify({'error': 'Product not found', 'message': str(e)}), 404

@product_bp.route('/products', methods=['POST'])
def create_product():
    """Create a new product"""
    try:
        data = request.get_json()
        
        # Validate required fields
        if not data or not data.get('name') or not data.get('price'):
            return jsonify({'error': 'Name and price are required'}), 400
        
        # Validate price format
        try:
            price = Decimal(str(data['price']))
            if price < 0:
                return jsonify({'error': 'Price must be non-negative'}), 400
        except (InvalidOperation, ValueError):
            return jsonify({'error': 'Invalid price format'}), 400
        
        # Create new product
        product = Product(
            name=data['name'].strip(),
            description=data.get('description', '').strip(),
            price=price
        )
        
        db.session.add(product)
        db.session.commit()
        
        return jsonify(product.to_dict()), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to create product', 'message': str(e)}), 500

@product_bp.route('/products/<int:product_id>', methods=['PUT'])
def update_product(product_id):
    """Update an existing product"""
    try:
        product = Product.query.get_or_404(product_id)
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        # Update fields if provided
        if 'name' in data:
            if not data['name'].strip():
                return jsonify({'error': 'Name cannot be empty'}), 400
            product.name = data['name'].strip()
        
        if 'description' in data:
            product.description = data['description'].strip()
        
        if 'price' in data:
            try:
                price = Decimal(str(data['price']))
                if price < 0:
                    return jsonify({'error': 'Price must be non-negative'}), 400
                product.price = price
            except (InvalidOperation, ValueError):
                return jsonify({'error': 'Invalid price format'}), 400
        
        db.session.commit()
        return jsonify(product.to_dict()), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to update product', 'message': str(e)}), 500

@product_bp.route('/products/<int:product_id>', methods=['DELETE'])
def delete_product(product_id):
    """Delete a product"""
    try:
        product = Product.query.get_or_404(product_id)
        db.session.delete(product)
        db.session.commit()
        
        return jsonify({'message': 'Product deleted successfully'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to delete product', 'message': str(e)}), 500

@product_bp.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'service': 'product-api'}), 200

