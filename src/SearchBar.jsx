import React, { useState } from 'react';

function SearchBar() {
  const [searchTerm, setSearchTerm] = useState('');
  
  // قائمة الأدوية بالإنجليزية بالكامل
  const medicines = [
    { id: 1, name: 'Panadol 500 mg', generic: 'Paracetamol', status: 'Available' },
    { id: 2, name: 'Brufen 400 mg', generic: 'Ibuprofen', status: 'Available' }
  ];

  return (
    <div className="w-full min-h-screen bg-blue-950 text-white pb-24 relative ltr-text">
      {/* المحتوى الرئيسي يمتد بعرض الشاشة */}
      <div className="w-full p-4">
        
        {/* الهيدر العلوي */}
        <div className="flex justify-between items-center mb-6">
          <span className="text-xl text-gray-300 hover:text-white cursor-pointer">
            <i className="fa-solid fa-arrow-right-to-bracket"></i>
          </span>
          <h1 className="text-2xl font-bold text-white">
            GazaPharma <span className="text-blue-400">Link</span>
          </h1>
          <span className="text-xl text-gray-300 hover:text-white cursor-pointer">
            <i className="fa-solid fa-bell"></i>
          </span>
        </div>

        {/* عنوان البحث بالإنجليزية */}
        <h2 className="text-sm font-semibold text-blue-200 mb-3 text-left">
          Search for medicine or active ingredient:
        </h2>

        {/* حقل البحث بالخلفية البيضاء بالكامل والنصوص الإنجليزية */}
        <div className="w-full mb-6">
          <div className="relative flex items-center bg-white rounded-xl shadow-md px-3 py-1.5">
            
            {/* أيقونة البحث في اليسار */}
            <span className="absolute left-3 text-gray-400">
              <i className="fa-solid fa-magnifying-glass"></i>
            </span>

            {/* حقل الإدخال بخلفية بيضاء ونصوص إنجليزية */}
            <input
              type="text"
              placeholder="Enter commercial or scientific medicine name..."
              className="w-full pl-8 pr-2 py-2 text-left text-gray-900 bg-white focus:outline-none text-sm placeholder-gray-400"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
            
            {/* أيقونة الفلتر الجانبية في اليمين */}
            <button className="text-blue-900 hover:text-blue-950 mr-2">
              <i className="fa-solid fa-sliders text-lg"></i>
            </button>
          </div>
        </div>

        {/* الأدوية الأكثر بحثاً بالإنجليزية */}
        <h3 className="text-xs font-medium text-blue-300 mb-3 text-left">
          Most Searched Medicines
        </h3>

        {/* قائمة استعراض الأدوية المنسقة داخل التصميم الكحلي */}
        <div className="space-y-3 w-full">
          {medicines.map((med) => (
            <div key={med.id} className="flex justify-between items-center p-4 bg-blue-900/40 rounded-xl border border-blue-800 hover:bg-blue-900/60 transition-all shadow-sm">
              <div className="text-left">
                <h4 className="font-bold text-white text-sm">{med.name}</h4>
                <p className="text-xs text-blue-300 mt-0.5 flex items-center gap-1">
                  <i className="fa-solid fa-flask text-[10px]"></i> {med.generic}
                </p>
              </div>
              <span className="bg-green-500/20 text-green-300 text-xs px-2.5 py-1 rounded-full font-medium">
                {med.status}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* زر الخريطة السفلي المثبت بالإنجليزية */}
      <div className="absolute bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-blue-950 via-blue-950 to-transparent">
        <button className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-xl shadow-lg transition-colors flex items-center justify-center gap-2 text-sm">
          <i className="fa-solid fa-map-location-dot"></i>
          Show on Map
        </button>
      </div>

    </div>
  );
}

export default SearchBar;