import express from 'express';
import {
  getAllAlerts,
  getUnresolvedAlerts,
  getAlertsByProduct,
  resolveAlert,
  deleteAlert
} from '../controllers/alertController.js';

const router = express.Router();

router.get('/', getAllAlerts);
router.get('/unresolved', getUnresolvedAlerts);
router.get('/product/:productId', getAlertsByProduct);
router.patch('/:id/resolve', resolveAlert);
router.delete('/:id', deleteAlert);

export default router;
