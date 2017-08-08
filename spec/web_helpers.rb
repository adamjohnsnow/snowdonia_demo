def set_up_users
  will = User.create('Will', 'Jackson', 'will@factorysettings.co.uk', 'f4ct0ry', 'Manager')
  will.update(:level => 3)
  adam = User.create('Adam', 'Snow', 'adamjohnsnow@icloud.com', 'b33chw00d', 'Developer')
  adam.update(:level => 3)
  Client.create(:name => "Dummy Client", :address => '1 High Street, London, E1 1AB', :manager => 'That Guy')
  Site.create(:name => "Dummy Site", :contact_name => 'Mrs Site', :address => '1 Site Lane, Sitetown, S12 1QW')
  categories = ["Fabrics", "Hardware"]
  categories.each { |category| Category.create(:type => category)}
  suppliers = ["Aalco", "Access"]
  suppliers.each { |supplier| Supplier.create(:company => supplier)}
  Material.create(:description => "Cotton Scene Canvas Unbleached - 300cm - Roll", :supplier_id => 1, :category_id => 1, :unit_cost => 6.9)
  Material.create(:description => "Calico 195gsm - 320cm - Roll", :supplier_id => 2, :category_id => 2, :unit_cost => 3.9)
end
