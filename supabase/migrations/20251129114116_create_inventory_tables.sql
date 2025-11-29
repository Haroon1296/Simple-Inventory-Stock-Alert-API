/*
  # Create Inventory and Stock Alert Tables

  1. New Tables
    - `products`
      - `id` (uuid, primary key)
      - `name` (text, required) - Product name
      - `sku` (text, unique, required) - Stock Keeping Unit
      - `description` (text) - Product description
      - `quantity` (integer, default 0) - Current stock quantity
      - `min_stock_level` (integer, default 10) - Minimum stock threshold for alerts
      - `price` (decimal) - Product price
      - `category` (text) - Product category
      - `created_at` (timestamptz) - Creation timestamp
      - `updated_at` (timestamptz) - Last update timestamp

    - `stock_alerts`
      - `id` (uuid, primary key)
      - `product_id` (uuid, foreign key) - Reference to products table
      - `alert_type` (text) - Type of alert (low_stock, out_of_stock)
      - `message` (text) - Alert message
      - `is_resolved` (boolean, default false) - Alert resolution status
      - `created_at` (timestamptz) - Alert creation timestamp
      - `resolved_at` (timestamptz) - Alert resolution timestamp

  2. Security
    - Enable RLS on both tables
    - Add policies for authenticated users to manage inventory
    - Add policies for reading stock alerts

  3. Important Notes
    - Products must have unique SKUs
    - Stock alerts are automatically created when quantity falls below min_stock_level
    - Quantity cannot be negative
*/

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  sku text UNIQUE NOT NULL,
  description text,
  quantity integer DEFAULT 0 CHECK (quantity >= 0),
  min_stock_level integer DEFAULT 10,
  price decimal(10, 2),
  category text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create stock_alerts table
CREATE TABLE IF NOT EXISTS stock_alerts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  alert_type text NOT NULL CHECK (alert_type IN ('low_stock', 'out_of_stock')),
  message text NOT NULL,
  is_resolved boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  resolved_at timestamptz
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_products_sku ON products(sku);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_stock_alerts_product_id ON stock_alerts(product_id);
CREATE INDEX IF NOT EXISTS idx_stock_alerts_is_resolved ON stock_alerts(is_resolved);

-- Enable Row Level Security
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_alerts ENABLE ROW LEVEL SECURITY;

-- Products policies
CREATE POLICY "Anyone can view products"
  ON products FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert products"
  ON products FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update products"
  ON products FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete products"
  ON products FOR DELETE
  TO authenticated
  USING (true);

-- Stock alerts policies
CREATE POLICY "Anyone can view stock alerts"
  ON stock_alerts FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert stock alerts"
  ON stock_alerts FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update stock alerts"
  ON stock_alerts FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete stock alerts"
  ON stock_alerts FOR DELETE
  TO authenticated
  USING (true);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to create stock alerts automatically
CREATE OR REPLACE FUNCTION check_stock_level()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if quantity is 0 (out of stock)
  IF NEW.quantity = 0 THEN
    INSERT INTO stock_alerts (product_id, alert_type, message)
    VALUES (
      NEW.id,
      'out_of_stock',
      'Product "' || NEW.name || '" is out of stock'
    );
  -- Check if quantity is below minimum stock level
  ELSIF NEW.quantity > 0 AND NEW.quantity <= NEW.min_stock_level THEN
    INSERT INTO stock_alerts (product_id, alert_type, message)
    VALUES (
      NEW.id,
      'low_stock',
      'Product "' || NEW.name || '" has low stock (' || NEW.quantity || ' remaining)'
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically create stock alerts
CREATE TRIGGER trigger_check_stock_level
  AFTER INSERT OR UPDATE OF quantity ON products
  FOR EACH ROW
  EXECUTE FUNCTION check_stock_level();
