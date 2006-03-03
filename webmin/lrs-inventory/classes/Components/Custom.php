<?php 

include_once ('Component.php');

/**
 * Hardware class contains all informations about one's machine hardware.
 *
 * @author Ludovic Drolez (Linbox FAS)
 */
class Custom extends Component
{
  function Custom ()
  {
    $this->m_Properties = array ('BuyDate' =>'',
				 'DeliveryDate' =>'',
				 'WorkingDate' =>'',
				 'WarrantyEnd' =>'',
				 'SupportEnd' =>'',
				 'Department' =>'',
				 'Location' =>'',
				 'Phone' =>'',
				 'Comments' =>'',
				 'BuyValue' =>'', 
				 'ResidualValue' =>'',
				 );

    // could have used gettext, but it will be much slower since gettext will be called each
    //   time an object will be instanciated
    $this->m_Desc = array ( 'BuyDate' => array('en'=>'buy date', 'fr'=>'date d\'achat'),
			'DeliveryDate' => array('en'=>'delivery date', 'fr'=>'date de livraison'),
			'WorkingDate' => array('en'=>'working date', 'fr'=>'date de mise en service'),
			'WarrantyEnd' => array('en'=>'warranty end date', 'fr'=>'date de fin de garantie'),
			'SupportEnd' => array('en'=>'support end date', 'fr'=>'date de fin de support'),
			'Department' => array('en'=>'department', 'fr'=>'service'),
			'Location' => array('en'=>'location', 'fr'=>'lieu'),
			'Phone' => array('en'=>'phone', 'fr'=>'téléphone'),
			'Comments' => array('en'=>'comments', 'fr'=>'commentaires'),
			'BuyValue' => array('en'=>'buy value', 'fr'=>'valeur d\'achat'), 
			'ResidualValue' => array('en'=>'residual value', 'fr'=>'valeur résiduelle'),
			);
  }
  
}

?>
