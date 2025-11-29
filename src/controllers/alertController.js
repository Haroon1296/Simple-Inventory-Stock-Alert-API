import { supabase } from '../config/supabase.js';

export const getAllAlerts = async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('stock_alerts')
      .select(`
        *,
        products (
          id,
          name,
          sku,
          quantity
        )
      `)
      .order('created_at', { ascending: false });

    if (error) throw error;

    res.json({
      success: true,
      data: data
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

export const getUnresolvedAlerts = async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('stock_alerts')
      .select(`
        *,
        products (
          id,
          name,
          sku,
          quantity
        )
      `)
      .eq('is_resolved', false)
      .order('created_at', { ascending: false });

    if (error) throw error;

    res.json({
      success: true,
      data: data
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

export const getAlertsByProduct = async (req, res) => {
  try {
    const { productId } = req.params;

    const { data, error } = await supabase
      .from('stock_alerts')
      .select(`
        *,
        products (
          id,
          name,
          sku,
          quantity
        )
      `)
      .eq('product_id', productId)
      .order('created_at', { ascending: false });

    if (error) throw error;

    res.json({
      success: true,
      data: data
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

export const resolveAlert = async (req, res) => {
  try {
    const { id } = req.params;

    const { data, error } = await supabase
      .from('stock_alerts')
      .update({
        is_resolved: true,
        resolved_at: new Date().toISOString()
      })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;

    res.json({
      success: true,
      data: data,
      message: 'Alert resolved successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

export const deleteAlert = async (req, res) => {
  try {
    const { id } = req.params;

    const { error } = await supabase
      .from('stock_alerts')
      .delete()
      .eq('id', id);

    if (error) throw error;

    res.json({
      success: true,
      message: 'Alert deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};
