class GarbageType < ActiveHash::Base
  self.data = [
    {id: 0, name: '----'},
    {id: 1, name: '燃えるゴミ'},
    {id: 2, name: '燃えないゴミ'},
    {id: 3, name: '資源ごみ（カン・ビン）'},
    {id: 4, name: '資源ごみ（ペット）'},
    {id: 5, name: '古紙'}
  ]
end