
class MaskHelper {
  MaskHelper._();

  static String? bankCardMask(String? txt){
    if(txt == null || txt.isEmpty){
      return null;
    }

    final reg = RegExp(r'(\d{1,4})');
    final mat = reg.allMatches(txt).toList();
    var res = '';

    for(final g in mat){
      if(g.group(0) != null) {
        res += '${g.group(0)} ';
      }
    }

    return res;
  }
}