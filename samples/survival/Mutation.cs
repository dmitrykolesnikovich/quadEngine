using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Survival
{    
    public abstract class Mutation
    {
        
    }

    public abstract class MutationSpread : Mutation  { }

    public abstract class MutationResist : Mutation { }

    public abstract class MutationOther: Mutation { }
}
